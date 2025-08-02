import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Утилита для работы с изображениями в приложении
class ImageUtil {
  ImageUtil._(); // Приватный конструктор — утилита не должна инстанцироваться

  /// Показывает индикатор загрузки изображения, пока оно подгружается
  /// Используется внутри Image.network(..., loadingBuilder: ...)
  static Widget loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) {
      return child; // Изображение загружено — возвращаем как есть
    }

    return Center(
      child: CircularProgressIndicator.adaptive(
        backgroundColor: Colors.white,
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  /// Загружает изображение из assets и масштабирует до нужного размера
  /// Удобно для отображения иконок, маркеров на карте и др.
  static Future<Image> loadAssetImage(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) async {
    final bytes = await rootBundle.load(path);
    final image = Image.memory(
      bytes.buffer.asUint8List(),
      width: width,
      height: height,
      fit: fit,
    );
    return image;
  }

  /// Быстрое создание [Image.network] с индикатором загрузки
  static Widget network(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    BorderRadius? borderRadius,
  }) {
    final image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      loadingBuilder: ImageUtil.loadingBuilder,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }

    return image;
  }
}
