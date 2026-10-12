/// Module: messaging / chat / domain/enum/file_types.dart
///
/// FIXED (bug report #18): the icons pointed at assets/png_assets/images_pdf.png
/// and images_xls.png, which are not in the project, so the doc bubble drew an
/// empty square. They now use the svgs that ship in main_icons_assets.
enum FileTypes {
  pdf,
  word,
  excel,
  powerpoint;

  static const String _base = 'assets/icons_assets/main_icons_assets';

  static String getFileIcon(String filePath) {
    switch (getFileType(filePath)) {
      case FileTypes.pdf:
        return '$_base/pdf_file_red.svg';
      case FileTypes.word:
        return '$_base/doc_file_blue.svg';
      case FileTypes.excel:
        return '$_base/excell.svg';
      case FileTypes.powerpoint:
        return '$_base/ppt_attachment_icon.svg';
    }
  }

  static FileTypes getFileType(String filePath) {
    // Storage download URLs end in "?alt=media&token=…", so strip the query
    // before looking at the extension, and ignore case (".PDF").
    final String path = filePath.split('?').first.toLowerCase();
    if (path.endsWith('.pdf')) {
      return FileTypes.pdf;
    } else if (path.endsWith('.doc') || path.endsWith('.docx')) {
      return FileTypes.word;
    } else if (path.endsWith('.xls') || path.endsWith('.xlsx')) {
      return FileTypes.excel;
    } else if (path.endsWith('.ppt') || path.endsWith('.pptx')) {
      return FileTypes.powerpoint;
    }
    return FileTypes.pdf;
  }
}
