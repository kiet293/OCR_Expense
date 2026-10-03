import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/ocr_service.dart';

/// Màn hình xử lý và hiển thị kết quả OCR (Phase 4)
/// Quy trình:
/// - Chạy Google ML Kit Text Recognition ngoại tuyến
/// - Hiển thị trạng thái đang xử lý (loading state)
/// - Trình bày toàn bộ Raw OCR Text đã nhận diện được
/// - Cung cấp khả năng tiếp tục sang bộ bóc tách Regex Heuristic (Phase 5)
class OcrProcessingScreen extends StatefulWidget {
  final String imagePath;

  const OcrProcessingScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<OcrProcessingScreen> createState() => _OcrProcessingScreenState();
}

class _OcrProcessingScreenState extends State<OcrProcessingScreen> {
  bool _isLoading = true;
  OcrResult? _ocrResult;

  @override
  void initState() {
    super.initState();
    _startOcrProcess();
  }

  Future<void> _startOcrProcess() async {
    setState(() {
      _isLoading = true;
    });

    final result = await OcrService.recognizeText(widget.imagePath);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _ocrResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Phân Tích OCR'),
        actions: [
          if (!_isLoading && _ocrResult != null && _ocrResult!.isSuccess)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Quét lại',
              onPressed: _startOcrProcess,
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoadingView() : _buildResultView(),
      ),
    );
  }

  /// Giao diện khi đang xử lý OCR
  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ảnh hóa đơn thu nhỏ
            Container(
              width: 130,
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: kIsWeb
                  ? Image.network(widget.imagePath, fit: BoxFit.cover)
                  : Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
            const SizedBox(height: 32),

            // Spinner & Tiến trình
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Đang phân tích hóa đơn...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Google ML Kit đang đọc từng dòng chữ ngoại tuyến trên thiết bị...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Giao diện hiển thị kết quả Raw Text sau khi OCR hoàn tất
  Widget _buildResultView() {
    final result = _ocrResult;
    if (result == null || !result.isSuccess) {
      return _buildErrorView(result?.errorMessage);
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thẻ thông tin nhanh
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nhận diện OCR hoàn tất!',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Đã tìm thấy ${result.lines.length} dòng văn bản từ ảnh hóa đơn.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tiêu đề nội dung OCR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nội dung nhận diện (Raw OCR Text)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${result.lines.length} dòng',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Khung hiển thị Raw Text với phông chữ monospace rõ nét
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    result.rawText.trim(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Nút hành động phía dưới
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Quay lại'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text(
                          'Sẵn sàng chuyển sang Phase 5: Bóc tách Regex Heuristic (Merchant, Date, Total)!',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  label: const Text(
                    'Tiếp tục phân tích dữ liệu',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Giao diện xử lý khi không tìm thấy chữ hoặc OCR lỗi
  Widget _buildErrorView(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.text_snippet_outlined,
                size: 54,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Không thể nhận diện hóa đơn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Ảnh quá mờ hoặc không có ký tự chữ. Bạn có thể chụp lại hoặc nhập thông tin thủ công.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Chụp lại'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Tiếp tục cho nhập thủ công
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Nhập thủ công'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
