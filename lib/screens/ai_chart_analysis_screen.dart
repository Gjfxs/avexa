import 'dart:io';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../theme.dart';
import '../widgets/app_page_header.dart';

class AiChartAnalysisScreen extends StatefulWidget {
  const AiChartAnalysisScreen({super.key});

  @override
  State<AiChartAnalysisScreen> createState() =>
      _AiChartAnalysisScreenState();
}

class _AiChartAnalysisScreenState
    extends State<AiChartAnalysisScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  CameraController? _cameraController;

  File? _selectedImage;

  bool _cameraActive = false;
  bool _cameraStarting = false;
  bool _isAnalyzing = false;

  // ================================================================
  // ANALYZE CHART
  // ================================================================

  Future<void> _analyzeChart() async {
    if (_selectedImage == null || _isAnalyzing) {
      debugPrint('AI CHART: No image or already analyzing.');
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    debugPrint('AI CHART: Starting analysis...');

    setState(() {
      _isAnalyzing = true;
    });

    try {
      debugPrint('AI CHART: Reading image...');

      final bytes = await _selectedImage!.readAsBytes();

      debugPrint(
        'AI CHART: Image size: ${bytes.length} bytes',
      );

      final base64Image = base64Encode(bytes);

      final path = _selectedImage!.path.toLowerCase();

      final mimeType = path.endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';

      final imageData = 'data:$mimeType;base64,$base64Image';

      debugPrint('AI CHART: Image converted to base64.');

      debugPrint(
        'AI CHART: Calling Supabase chart-analysis...',
      );

      final response =
          await Supabase.instance.client.functions.invoke(
        'super-task',
        body: {
          'image': imageData,
        },
      );

      debugPrint('AI CHART: Supabase response received.');

      debugPrint(
        'AI CHART: Response data: ${response.data}',
      );

      final data = response.data;

      if (data == null) {
        throw Exception('Supabase returned no data.');
      }

      if (data is! Map) {
        throw Exception(
          l10n.aiChartUnexpectedResponseError(data.toString()),
        );
      }

      if (data['error'] != null) {
        throw Exception(data['error'].toString());
      }

      final analysis = data['analysis']?.toString();

      if (analysis == null || analysis.trim().isEmpty) {
        throw Exception(l10n.aiChartEmptyAnalysisError);
      }

      final rawStructured = data['analysis_data'];
      final Map<String, dynamic>? structuredAnalysis =
          rawStructured is Map
              ? Map<String, dynamic>.from(rawStructured)
              : null;

      debugPrint(
        'AI CHART: Structured data available: '
        '${structuredAnalysis != null}',
      );

      debugPrint('AI CHART: Analysis received successfully.');

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      _showAnalysisResult(
        analysis,
        structured: structuredAnalysis,
      );
    } catch (e, stackTrace) {
      debugPrint('AI CHART ERROR: $e');

      debugPrint(
        'AI CHART STACK TRACE:\n$stackTrace',
      );

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.aiChartAnalysisError(e.toString()),
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  // ================================================================
  // SHOW ANALYSIS RESULT
  // ================================================================

  void _showAnalysisResult(
    String analysis, {
    Map<String, dynamic>? structured,
  }) {
    final colors = Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      showDragHandle: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.88,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: neonBlue.withOpacity(.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: neonBlue.withOpacity(.20),
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: neonBlue,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.aiChartAnalysisTitle,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: structured != null
                        ? _StructuredAnalysisView(
                            data: structured,
                            fallbackText: analysis,
                            colors: colors,
                          )
                        : SingleChildScrollView(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: colors.elevatedCard,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: colors.border),
                              ),
                              child: SelectableText(
                                analysis,
                                style: GoogleFonts.poppins(
                                  color: colors.primaryText,
                                  fontSize: 13,
                                  height: 1.65,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.check_rounded, size: 19),
                      label: Text(
                        l10n.aiChartDone,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================================================================
  // START CAMERA
  // ================================================================

  Future<void> _startCamera() async {
    if (_cameraStarting || _cameraActive) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _cameraStarting = true;
    });

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception(l10n.aiChartCameraUnavailable);
      }

      CameraDescription selectedCamera = cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _cameraController = controller;

      setState(() {
        _cameraActive = true;
        _cameraStarting = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cameraStarting = false;
      });

      _showError(l10n.aiChartCameraError);
    }
  }

  // ================================================================
  // TAKE PHOTO
  // ================================================================

  Future<void> _takePhoto() async {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      final XFile image = await controller.takePicture();

      if (!mounted) return;

      setState(() {
        _selectedImage = File(image.path);
        _cameraActive = false;
      });

      await controller.dispose();

      _cameraController = null;
    } catch (e) {
      if (!mounted) return;

      _showError(
        AppLocalizations.of(context)!.aiChartCaptureError,
      );
    }
  }

  // ================================================================
  // PICK FROM GALLERY
  // ================================================================

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (image == null) return;

      await _stopCamera();

      if (!mounted) return;

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      _showError(
        AppLocalizations.of(context)!.aiChartSelectImageError,
      );
    }
  }

  // ================================================================
  // STOP CAMERA
  // ================================================================

  Future<void> _stopCamera() async {
    final controller = _cameraController;

    _cameraController = null;

    if (mounted) {
      setState(() {
        _cameraActive = false;
      });
    }

    await controller?.dispose();
  }

  // ================================================================
  // DISPOSE
  // ================================================================

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ================================================================
  // CANCEL SELECTED IMAGE
  // ================================================================

  void _cancelSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  // ================================================================
  // ERROR
  // ================================================================

  void _showError(String message) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 12,
          ),
        ),
        backgroundColor: colors.elevatedCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep the controls above the app's overlaid bottom nav.
            // The reserved space prevents overlap on different screen sizes.
            final bottomNavClearance =
                MediaQuery.of(context).size.height < 700 ? 100.0 : 112.0;

            return Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: AppPageHeader(
                    title: l10n.aiChartTitle,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Text(
                    l10n.aiChartDescription,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // SCANNER: scrollable and constrained to available space
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, scannerConstraints) {
                      final availableHeight =
                          scannerConstraints.maxHeight;

                      // Limit scanner height so controls have their own space.
                      final scannerHeight =
                          (availableHeight * 0.94).clamp(180.0, 680.0);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: scannerHeight,
                            ),
                            child: AspectRatio(
                              aspectRatio: 0.68,
                              child: _ChartScannerFrame(
                                colors: colors,
                                cameraController: _cameraController,
                                cameraActive: _cameraActive,
                                cameraStarting: _cameraStarting,
                                selectedImage: _selectedImage,
                                onEnableCamera: _startCamera,
                                onCancelImage: _cancelSelectedImage,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // CONTROLS: fixed outside the scanner's scroll view
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    bottomNavClearance,
                  ),
                  child: _selectedImage == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ScannerActionButton(
                              icon: Icons.photo_library_outlined,
                              colors: colors,
                              onTap: _pickFromGallery,
                            ),

                            const Spacer(),

                            _CameraButton(
                              active: _cameraActive,
                              onTap: _cameraActive
                                  ? _takePhoto
                                  : _startCamera,
                            ),

                            const Spacer(),

                            _ScannerActionButton(
                              icon: Icons.history_rounded,
                              colors: colors,
                              purple: true,
                              onTap: () {
                                _showAnalysisHistory(
                                  context,
                                  colors,
                                );
                              },
                            ),
                          ],
                        )
                      : _AnalyzeButton(
                          analyzing: _isAnalyzing,
                          onTap: _analyzeChart,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================================================================
  // HISTORY
  // ================================================================

  Future<List<Map<String, dynamic>>> _loadAnalysisHistory() async {
    final cutoff = DateTime.now().toUtc().subtract(
          const Duration(hours: 24),
        );

    final response = await Supabase.instance.client
        .from('ai_chart_analyses')
        .select('id, analysis, created_at')
        .gte(
          'created_at',
          cutoff.toIso8601String(),
        )
        .order(
          'created_at',
          ascending: false,
        );

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _showAnalysisHistory(
    BuildContext context,
    AvexaColors colors,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Drag handle
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6)
                                .withOpacity(0.14),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: Color(0xFF8B5CF6),
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.aiChartAnalysisHistory,
                                style: GoogleFonts.inter(
                                  color: colors.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                l10n.aiChartRecentAnalyses,
                                style: GoogleFonts.inter(
                                  color: colors.secondaryText,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () =>
                              Navigator.pop(sheetContext),
                          icon: Icon(
                            Icons.close_rounded,
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 24h notice
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: colors.secondaryText,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.aiChartHistoryNotice,
                              style: GoogleFonts.inter(
                                color: colors.secondaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: FutureBuilder<
                        List<Map<String, dynamic>>>(
                      future: _loadAnalysisHistory(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: neonBlue,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: colors.secondaryText,
                                    size: 38,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    l10n.aiChartHistoryLoadError,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: colors.primaryText,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.aiChartTryAgainLater,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: colors.secondaryText,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final analyses = snapshot.data ?? [];

                        if (analyses.isEmpty) {
                          return _emptyAnalysisHistory(colors);
                        }

                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            24,
                          ),
                          itemCount: analyses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = analyses[index];

                            final analysis =
                                item['analysis']?.toString() ?? '';

                            final createdAt = DateTime.tryParse(
                              item['created_at']?.toString() ?? '',
                            );

                            return _AnalysisHistoryCard(
                              analysis: analysis,
                              createdAt: createdAt,
                              colors: colors,
                              onTap: () {
                                _showSavedAnalysis(analysis);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyAnalysisHistory(AvexaColors colors) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.card,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.border,
                ),
              ),
              child: Icon(
                Icons.history_rounded,
                color: colors.mutedText,
                size: 30,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              l10n.aiChartNoAnalyses,
              style: GoogleFonts.inter(
                color: colors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              l10n.aiChartHistoryEmptyDescription,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: colors.secondaryText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SHOW SAVED ANALYSIS
  // ================================================================

  void _showSavedAnalysis(String analysis) {
    final colors =
        Theme.of(context).extension<AvexaColors>()!;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              14,
              20,
              24,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .78,
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: neonBlue.withOpacity(.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: neonBlue.withOpacity(.20),
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: neonBlue,
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          l10n.aiChartAnalysisTitle,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.elevatedCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors.border,
                          ),
                        ),
                        child: Text(
                          analysis,
                          style: GoogleFonts.poppins(
                            color: colors.primaryText,
                            fontSize: 13,
                            height: 1.65,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.check_rounded,
                        size: 19,
                      ),
                      label: Text(
                        l10n.aiChartDone,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class _StructuredAnalysisView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String fallbackText;
  final AvexaColors colors;

  const _StructuredAnalysisView({
    required this.data,
    required this.fallbackText,
    required this.colors,
  });

  String _text(String key) {
    final value = data[key];
    if (value == null || value.toString().trim().isEmpty) {
      return 'Not visible';
    }
    return value.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final trend = _text('trend');
    final momentum = _text('momentum');
    final risk = _text('risk');
    final confidenceValue = data['confidence'];
    final confidence = confidenceValue is num
        ? confidenceValue.toDouble().clamp(0.0, 100.0)
        : double.tryParse('$confidenceValue')
                ?.clamp(0.0, 100.0) ??
            0.0;

    final trendColor = trend.toLowerCase().contains('bullish')
        ? const Color(0xFF00C896)
        : trend.toLowerCase().contains('bearish')
            ? const Color(0xFFFF526B)
            : neonBlue;

    final riskColor = risk.toLowerCase() == 'high'
        ? const Color(0xFFFF526B)
        : risk.toLowerCase() == 'low'
            ? const Color(0xFF00C896)
            : const Color(0xFFFFC857);

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        // TREND SUMMARY
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.elevatedCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OVERALL TREND',
                style: GoogleFonts.inter(
                  color: colors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    trend.toLowerCase().contains('bullish')
                        ? Icons.trending_up_rounded
                        : trend.toLowerCase().contains('bearish')
                            ? Icons.trending_down_rounded
                            : Icons.trending_flat_rounded,
                    color: trendColor,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      trend,
                      style: GoogleFonts.poppins(
                        color: trendColor,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _text('trend_summary'),
                style: GoogleFonts.inter(
                  color: colors.primaryText,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // MOMENTUM AND RISK
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InsightCard(
                title: 'MOMENTUM',
                value: momentum,
                icon: Icons.bolt_rounded,
                accent: neonBlue,
                colors: colors,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InsightCard(
                title: 'RISK',
                value: risk,
                icon: Icons.shield_outlined,
                accent: riskColor,
                colors: colors,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // AI CONFIDENCE
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: colors.elevatedCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: neonBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'AI CONFIDENCE',
                      style: GoogleFonts.inter(
                        color: colors.primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                      ),
                    ),
                  ),
                  Text(
                    '${confidence.round()}%',
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: confidence / 100,
                  minHeight: 7,
                  backgroundColor: colors.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(neonBlue),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                _text('confidence_explanation'),
                style: GoogleFonts.inter(
                  color: colors.secondaryText,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'DETAILED ANALYSIS',
          style: GoogleFonts.inter(
            color: colors.secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        _DetailTile(
          title: 'Market Structure',
          icon: Icons.candlestick_chart_rounded,
          value: _text('market_structure'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Support',
          icon: Icons.south_rounded,
          value: _text('support'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Resistance',
          icon: Icons.north_rounded,
          value: _text('resistance'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Pattern',
          icon: Icons.schema_rounded,
          value: _text('pattern'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Trading Setup',
          icon: Icons.track_changes_rounded,
          value: _text('setup'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Entry',
          icon: Icons.login_rounded,
          value: _text('entry'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Stop Loss',
          icon: Icons.shield_outlined,
          value: _text('stop_loss'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Take Profit',
          icon: Icons.flag_outlined,
          value: _text('take_profit'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Risk / Reward',
          icon: Icons.balance_rounded,
          value: _text('risk_reward'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Risk Explanation',
          icon: Icons.warning_amber_rounded,
          value: _text('risk_explanation'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Market Sentiment',
          icon: Icons.insights_rounded,
          value: _text('sentiment'),
          colors: colors,
        ),
        _DetailTile(
          title: 'Recommendation',
          icon: Icons.lightbulb_outline_rounded,
          value: _text('recommendation'),
          colors: colors,
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final AvexaColors colors;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 130),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.elevatedCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: colors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final AvexaColors colors;

  const _DetailTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.elevatedCard,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          leading: Icon(icon, color: neonBlue, size: 21),
          title: Text(
            title,
            style: GoogleFonts.inter(
              color: colors.primaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconColor: neonBlue,
          collapsedIconColor: colors.secondaryText,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                value,
                style: GoogleFonts.inter(
                  color: colors.secondaryText,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// CHART SCANNER FRAME
// ================================================================

class _ChartScannerFrame extends StatelessWidget {
  final AvexaColors colors;
  final CameraController? cameraController;
  final bool cameraActive;
  final bool cameraStarting;
  final File? selectedImage;
  final VoidCallback onEnableCamera;
  final VoidCallback onCancelImage;

  const _ChartScannerFrame({
    required this.colors,
    required this.cameraController,
    required this.cameraActive,
    required this.cameraStarting,
    required this.selectedImage,
    required this.onEnableCamera,
    required this.onCancelImage,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.68,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            color: colors.elevatedCard,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ==================================================
              // PHOTO
              // ==================================================

              if (selectedImage != null)
                Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                )

              // ==================================================
              // LIVE CAMERA
              // ==================================================

              else if (cameraActive &&
                  cameraController != null &&
                  cameraController!.value.isInitialized)
                _LiveCameraPreview(
                  controller: cameraController!,
                )

              // ==================================================
              // INITIAL STATE
              // ==================================================

              else
                _CameraStartOverlay(
                  colors: colors,
                  loading: cameraStarting,
                  onEnable: onEnableCamera,
                ),

              // ==================================================
              // DARK OVERLAY ON CAMERA
              // ==================================================

              if (cameraActive)
                Container(
                  color: Colors.black.withOpacity(.08),
                ),

              // ==================================================
              // FRAME BORDER + CORNERS
              // ==================================================

              IgnorePointer(
                child: CustomPaint(
                  painter: _ScannerFramePainter(
                    borderColor: neonBlue.withOpacity(.75),
                    cornerColor: neonBlue,
                  ),
                  size: Size.infinite,
                ),
              ),

              // ==================================================
              // CLOSE BUTTON
              // ==================================================

              if (selectedImage != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: onCancelImage,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.65),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(.20),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CAMERA START OVERLAY
// ================================================================

class _CameraStartOverlay extends StatelessWidget {
  final AvexaColors colors;
  final bool loading;
  final VoidCallback onEnable;

  const _CameraStartOverlay({
    required this.colors,
    required this.loading,
    required this.onEnable,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: colors.elevatedCard,
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: neonBlue.withOpacity(.10),
              border: Border.all(
                color: neonBlue.withOpacity(.25),
              ),
            ),
            child: const Icon(
              Icons.document_scanner_outlined,
              color: neonBlue,
              size: 31,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            l10n.aiChartScannerTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            l10n.aiChartScannerDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: loading ? null : onEnable,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                    ),
              label: Text(
                loading
                    ? l10n.aiChartStartingCamera
                    : l10n.aiChartEnableCamera,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// LIVE CAMERA PREVIEW
// ================================================================

class _LiveCameraPreview extends StatelessWidget {
  final CameraController controller;

  const _LiveCameraPreview({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;

    if (size == null) {
      return CameraPreview(controller);
    }

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

// ================================================================
// SCANNER FRAME PAINTER
// ================================================================

class _ScannerFramePainter extends CustomPainter {
  final Color borderColor;
  final Color cornerColor;

  _ScannerFramePainter({
    required this.borderColor,
    required this.cornerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ============================================================
    // OUTER FRAME
    // ============================================================

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        1,
        1,
        size.width - 2,
        size.height - 2,
      ),
      const Radius.circular(28),
    );

    canvas.drawRRect(
      borderRect,
      borderPaint,
    );

    // ============================================================
    // CORNER ACCENTS
    // ============================================================

    final cornerPaint = Paint()
      ..color = cornerColor
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const double inset = 26;
    const double length = 38;

    // ------------------------------------------------------------
    // TOP LEFT
    // ------------------------------------------------------------

    final topLeft = Path()
      ..moveTo(inset, inset + length)
      ..lineTo(inset, inset)
      ..lineTo(inset + length, inset);

    canvas.drawPath(
      topLeft,
      cornerPaint,
    );

    // ------------------------------------------------------------
    // TOP RIGHT
    // ------------------------------------------------------------

    final topRight = Path()
      ..moveTo(size.width - inset - length, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, inset + length);

    canvas.drawPath(
      topRight,
      cornerPaint,
    );

    // ------------------------------------------------------------
    // BOTTOM LEFT
    // ------------------------------------------------------------

    final bottomLeft = Path()
      ..moveTo(inset, size.height - inset - length)
      ..lineTo(inset, size.height - inset)
      ..lineTo(inset + length, size.height - inset);

    canvas.drawPath(
      bottomLeft,
      cornerPaint,
    );

    // ------------------------------------------------------------
    // BOTTOM RIGHT
    // ------------------------------------------------------------

    final bottomRight = Path()
      ..moveTo(
        size.width - inset - length,
        size.height - inset,
      )
      ..lineTo(
        size.width - inset,
        size.height - inset,
      )
      ..lineTo(
        size.width - inset,
        size.height - inset - length,
      );

    canvas.drawPath(
      bottomRight,
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _ScannerFramePainter oldDelegate,
  ) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.cornerColor != cornerColor;
  }
}

// ================================================================
// SIDE BUTTON
// ================================================================

class _ScannerActionButton extends StatelessWidget {
  final IconData icon;
  final AvexaColors colors;
  final VoidCallback onTap;
  final bool purple;

  const _ScannerActionButton({
    required this.icon,
    required this.colors,
    required this.onTap,
    this.purple = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = purple
        ? const Color(0xFF7B61FF)
        : neonBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withOpacity(.055),
          border: Border.all(
            color: accent.withOpacity(.45),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(.08),
              blurRadius: 16,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: accent,
          size: 24,
        ),
      ),
    );
  }
}

// ================================================================
// CAMERA BUTTON
// ================================================================

class _CameraButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _CameraButton({
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 74,
        height: 74,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: neonBlue,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: neonBlue.withOpacity(.30),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: active
              ? const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.black54,
                  size: 25,
                )
              : null,
        ),
      ),
    );
  }
}

// ================================================================
// ANALYZE BUTTON
// ================================================================

class _AnalyzeButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool analyzing;

  const _AnalyzeButton({
    required this.onTap,
    required this.analyzing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: analyzing ? null : onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (analyzing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(
                Icons.auto_awesome_rounded,
                size: 19,
              ),

            const SizedBox(width: 9),

            Text(
              analyzing
                  ? l10n.aiChartAnalyzing
                  : l10n.aiChartAnalyze,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ANALYSIS HISTORY CARD
// ================================================================

class _AnalysisHistoryCard extends StatelessWidget {
  final String analysis;
  final DateTime? createdAt;
  final AvexaColors colors;
  final VoidCallback onTap;

  const _AnalysisHistoryCard({
    required this.analysis,
    required this.createdAt,
    required this.colors,
    required this.onTap,
  });

  String _formatTime() {
    if (createdAt == null) return '';

    final local = createdAt!.toLocal();

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _preview() {
    final clean = analysis.replaceAll('\n', ' ').trim();

    if (clean.length <= 120) {
      return clean;
    }

    return '${clean.substring(0, 120)}…';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: neonBlue,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.aiChartHistoryCardTitle,
                            style: GoogleFonts.inter(
                              color: colors.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(),
                          style: GoogleFonts.inter(
                            color: colors.mutedText,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _preview(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: colors.secondaryText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: colors.mutedText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}