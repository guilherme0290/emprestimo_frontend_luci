import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:emprestimos_app/core/theme/theme.dart';

class MyAwesomeDialog extends AwesomeDialog {
  MyAwesomeDialog({
    required BuildContext context,
    required String title,
    required String message,
    DialogType dialogType = DialogType.info,
    Function()? onOkPressed,
    Function()? onCancelPressed,
    String? btnOkText = 'Ok',
    String? btnCancelText = 'Cancelar',
  }) : super(
          context: context,
          dialogType: dialogType,
          headerAnimationLoop: true,
          animType: AnimType.scale,
          showCloseIcon: true,
          width: 340, // 🔹 Ajuste no tamanho para melhor legibilidade
          padding: const EdgeInsets.all(16), // 🔹 Maior espaço interno
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: true,

          /// 🔹 **Estilização da Borda**
          borderSide: BorderSide(
            color: _getBorderColor(dialogType),
            width: 2.5,
          ),
          buttonsBorderRadius: const BorderRadius.all(Radius.circular(12)),

          /// 🔹 **Título estilizado**
          title: title,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),

          /// 🔹 **Texto da mensagem**
          desc: message,
          descTextStyle: const TextStyle(
            fontSize: 16,
            color: AppTheme.textColor,
          ),

          /// 🔹 **Ícone personalizado por tipo de diálogo**
          customHeader: _buildDialogIcon(dialogType),

          /// 🔹 **Botão OK**
          btnOkOnPress: onOkPressed,
          btnOkText: btnOkText,
          btnOkColor: AppTheme.primaryColor,
          btnOkIcon: Icons.check,

          /// 🔹 **Botão Cancelar**
          btnCancelOnPress: onCancelPressed,
          btnCancelText: btnCancelText,
          btnCancelColor: AppTheme.secondaryColor,
          btnCancelIcon: Icons.close,
        );

  /// 🔹 **Define um ícone com base no tipo do diálogo**
  static Widget _buildDialogIcon(DialogType type) {
    IconData icon;
    Color bgColor;

    switch (type) {
      case DialogType.success:
        icon = Icons.check_circle;
        bgColor = Colors.green;
        break;
      case DialogType.warning:
        icon = Icons.warning;
        bgColor = Colors.orange;
        break;
      case DialogType.error:
        icon = Icons.error;
        bgColor = Colors.red;
        break;
      default:
        icon = Icons.info;
        bgColor = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor.withOpacity(0.1), // 🔹 Fundo sutil
      ),
      child: Icon(icon, color: bgColor, size: 40),
    );
  }

  /// 🔹 **Define a cor da borda com base no tipo do diálogo**
  static Color _getBorderColor(DialogType type) {
    switch (type) {
      case DialogType.success:
        return Colors.green;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.error:
        return Colors.red;
      default:
        return AppTheme.primaryColor;
    }
  }
}
