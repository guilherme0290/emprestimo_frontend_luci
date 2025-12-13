import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Definição da nova paleta de cores
  static const Color primaryColor = Color(0xFF0056B3); // Azul Royal
  static const Color secondaryColor = Color(0xFF002B5B); // Azul Escuro
  static const Color accentColor = Color(0xFF0099FF); // Ciano Suave
  static const Color backgroundColor = Color(0xFFF5F7FA); // Cinza Claro
  static const Color textColor = Color(0xFF1B1E23); // Preto Suave
  static const Color neutralColor = Color(0xFFF2F2F2);

  // Gradiente principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color.fromARGB(255, 0, 86, 179), Color.fromARGB(255, 0, 43, 91)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🔤 Estilos de Texto
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textColor,
  );

  // 🌟 Tema Principal - Light Mode
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Poppins',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppTheme.primaryColor,
        selectionColor: AppTheme.accentColor,
        selectionHandleColor: AppTheme.primaryColor,
      ),

      // Configuração de texto
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
        bodyMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.normal, color: textColor),
        titleLarge: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
        titleMedium: TextStyle(
          color: Color(0xFF1B1E23), // Cinza escuro
          fontSize: 16,
        ),
      ),

      // AppBar estilizada
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryColor,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 4,
        shadowColor: Colors.black26,
      ),

      // Botões mais elegantes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 3,
        ),
      ),

      // Inputs estilizados com gradiente
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        // labelStyle: const TextStyle(
        //   color: AppTheme.primaryColor, // ou qualquer cor desejada
        //   fontWeight: FontWeight.w600,
        // ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        floatingLabelStyle: const TextStyle(
          color: AppTheme.accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Estilo de Cards modernos com gradiente
      cardTheme: const CardThemeData(
        elevation: 5,
        color: Colors.white,
        surfaceTintColor:
            Colors.white, // Evita tonalidades inesperadas no Material 3
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
