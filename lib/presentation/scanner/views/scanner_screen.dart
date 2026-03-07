import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../domain/entities/product_entity.dart';
import '../controllers/scanner_controller.dart';
import '../../pantry/controllers/pantry_controller.dart';
import '../../../../domain/entities/pantry_item_entity.dart';

class ScannerScreen extends StatefulHookConsumerWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  late final MobileScannerController _cameraController;
  DateTime? _lastDetected;
  bool _isModalOpen = false;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // ── Barcode detection (debounced 2 seconds) ────────────────────────────────
  void _onBarcodeDetect(BarcodeCapture capture) {
    if (_isModalOpen) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode.isEmpty) return;

    final now = DateTime.now();
    if (_lastDetected != null &&
        now.difference(_lastDetected!) < const Duration(seconds: 2)) return;
    _lastDetected = now;

    // Dispatch to the ScannerController (triggers isCacheHit / remoteProduct / saveToLocal)
    ref.read(scannerControllerProvider.notifier).processBarcode(barcode);
  }

  // ── React to state changes ─────────────────────────────────────────────────
  void _handleStateChange(ScannerState? _, ScannerState next) {
    switch (next) {
      case ScannerSuccess(product: final p, isCacheHit: final hit):
        _showProductSheet(p, isCacheHit: hit);
      case ScannerError(message: final msg):
        _showErrorSheet(msg);
      default:
        break;
    }
  }

  // ── Product found Bottom Sheet ─────────────────────────────────────────────
  Future<void> _showProductSheet(ProductEntity product,
      {required bool isCacheHit}) async {
    _isModalOpen = true;
    await _cameraController.stop();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductConfirmationSheet(
        product: product,
        isCacheHit: isCacheHit,
        onConfirm: (grams, expiry) {
          final item = PantryItemEntity(
            id: 0,
            productBarcode: product.barcode,
            grams: grams,
            addedAt: DateTime.now(),
            expirationDate: expiry,
            isConsumed: false,
          );
          ref.read(pantryControllerProvider.notifier).addItem(item);
          Navigator.of(context).pop();
        },
      ),
    );

    _isModalOpen = false;
    ref.read(scannerControllerProvider.notifier).reset();
    await _cameraController.start();
  }

  // ── Error / offline Bottom Sheet ───────────────────────────────────────────
  Future<void> _showErrorSheet(String message) async {
    _isModalOpen = true;
    await _cameraController.stop();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OfflineGenericSheet(
        message: message,
        onGenericSave: (barcode, name) {
          // Build and save a generic product placeholder
          final item = PantryItemEntity(
            id: 0,
            productBarcode: barcode,
            grams: 100.0,
            addedAt: DateTime.now(),
            expirationDate: null,
            isConsumed: false,
          );
          ref.read(pantryControllerProvider.notifier).addItem(item);
          Navigator.of(ctx).pop();
        },
      ),
    );

    _isModalOpen = false;
    ref.read(scannerControllerProvider.notifier).reset();
    await _cameraController.start();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerControllerProvider);
    final isLoading = scannerState is ScannerLoadingProduct;

    ref.listen(scannerControllerProvider, _handleStateChange);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan Product'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera feed ─────────────────────────────────────────────────
          MobileScanner(
            controller: _cameraController,
            onDetect: _onBarcodeDetect,
            errorBuilder: (_, error, __) => _CameraError(error: error),
          ),

          // ── Dimmed overlay with transparent cutout ───────────────────────
          ColorFiltered(
            colorFilter:
                const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                    decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut)),
                Center(
                  child: Container(
                    width: 260,
                    height: 160,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),

          // ── Animated reticle ─────────────────────────────────────────────
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00E676), width: 2.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF00E676).withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 2)
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.97, end: 1.03, duration: 900.ms)
                .fade(begin: 0.85, end: 1.0),
          ),

          // ── Hint label ───────────────────────────────────────────────────
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              isLoading ? 'Looking up product…' : 'Align barcode inside the frame',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),

          // ── Loading spinner over camera ───────────────────────────────────
          if (isLoading)
            const ColoredBox(
              color: Colors.black45,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00E676)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Product Confirmation Sheet ────────────────────────────────────────────────
class _ProductConfirmationSheet extends StatefulWidget {
  final ProductEntity product;
  final bool isCacheHit;
  final void Function(double grams, DateTime? expiry) onConfirm;

  const _ProductConfirmationSheet(
      {required this.product,
      required this.isCacheHit,
      required this.onConfirm});

  @override
  State<_ProductConfirmationSheet> createState() =>
      _ProductConfirmationSheetState();
}

class _ProductConfirmationSheetState
    extends State<_ProductConfirmationSheet> {
  final _gramsController = TextEditingController(text: '100');
  DateTime? _expiry;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.product;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with image
          Row(
            children: [
              if (p.imageUrl != null)
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(p.imageUrl!,
                        width: 72, height: 72, fit: BoxFit.cover))
              else
                Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.fastfood_outlined,
                        color: Color(0xFF00E676), size: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (p.brand != null)
                      Text(p.brand!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: widget.isCacheHit
                              ? Colors.blue.withOpacity(0.15)
                              : Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                          widget.isCacheHit
                              ? '⚡ From cache'
                              : '🌐 From Open Food Facts',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: widget.isCacheHit
                                  ? Colors.lightBlueAccent
                                  : const Color(0xFF00E676))),
                    ),
                  ],
                ),
              )
            ],
          ),

          const Divider(height: 28),

          // Macros row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroBadge('Kcal', p.caloriesPer100g),
              _MacroBadge('Prot', p.proteinPer100g),
              _MacroBadge('Carbs', p.carbsPer100g),
              _MacroBadge('Fat', p.fatsPer100g),
            ],
          ),

          const SizedBox(height: 20),

          // Grams input
          TextField(
            controller: _gramsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (grams)',
              prefixIcon: Icon(Icons.scale_outlined),
              border: OutlineInputBorder(),
              suffixText: 'g',
            ),
          ),

          const SizedBox(height: 12),

          // Expiry date picker
          OutlinedButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                  context: context,
                  initialDate: now.add(const Duration(days: 7)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365 * 5)));
              if (picked != null) setState(() => _expiry = picked);
            },
            icon: const Icon(Icons.event_outlined),
            label: Text(_expiry == null
                ? 'Set expiry date (optional)'
                : 'Expires: ${_expiry!.day}/${_expiry!.month}/${_expiry!.year}'),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final g = double.tryParse(_gramsController.text) ?? 100.0;
                widget.onConfirm(g, _expiry);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Add to Pantry', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Offline Generic Product Sheet ─────────────────────────────────────────────
class _OfflineGenericSheet extends StatefulWidget {
  final String message;
  final void Function(String barcode, String name) onGenericSave;

  const _OfflineGenericSheet(
      {required this.message, required this.onGenericSave});

  @override
  State<_OfflineGenericSheet> createState() => _OfflineGenericSheetState();
}

class _OfflineGenericSheetState extends State<_OfflineGenericSheet> {
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24)),
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.orangeAccent, size: 48),
          const SizedBox(height: 12),
          Text('Product Not Found',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
              'No internet or product is not in the Open Food Facts database.\n'
              'Create a Generic Product to keep tracking it.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          TextField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                  labelText: 'Barcode',
                  prefixIcon: Icon(Icons.barcode_reader),
                  border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Product name',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder())),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final barcode = _barcodeController.text.trim();
                    final name = _nameController.text.trim();
                    if (barcode.isNotEmpty && name.isNotEmpty) {
                      widget.onGenericSave(barcode, name);
                    }
                  },
                  child: const Text('Save Generic'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Camera Error Widget ────────────────────────────────────────────────────────
class _CameraError extends StatelessWidget {
  final MobileScannerException error;

  const _CameraError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined,
                color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text('Camera unavailable',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
                'Make sure camera permissions are granted in Settings. '
                '(Error: ${error.errorCode.name})',
                style: const TextStyle(color: Colors.white60),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Macro Badge ────────────────────────────────────────────────────────────────
class _MacroBadge extends StatelessWidget {
  final String label;
  final double? value;

  const _MacroBadge(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value != null ? value!.toStringAsFixed(1) : '—',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
