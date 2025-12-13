import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelector {
  static Future<Map<String, DateTime>?> show(
    BuildContext context, {
    String? descricaoButton,
  }) async {
    DateTime? dataInicio;
    DateTime? dataFim;

    return await showModalBottomSheet<Map<String, DateTime>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.date_range,
                                size: 40,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(height: 8),
                            const Text(
                              "Selecionar Período",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDataTile(
                        context: context,
                        label: "Data Início",
                        data: dataInicio,
                        onTap: () async {
                          final picked = await showDatePicker(
                            locale: const Locale('pt', 'BR'),
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2022),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => dataInicio = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildDataTile(
                        context: context,
                        label: "Data Fim",
                        data: dataFim,
                        onTap: () async {
                          final picked = await showDatePicker(
                            locale: const Locale('pt', 'BR'),
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2022),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => dataFim = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: Text(descricaoButton ?? "Buscar",
                              style: const TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (dataInicio != null && dataFim != null) {
                              Navigator.pop(context, {
                                'dataInicio': dataInicio!,
                                'dataFim': dataFim!,
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Widget _buildDataTile({
    required BuildContext context,
    required String label,
    required DateTime? data,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data == null ? label : DateFormat('dd/MM/yyyy').format(data),
              style: TextStyle(
                fontSize: 16,
                color: data == null ? Colors.grey.shade600 : Colors.black,
              ),
            ),
            Icon(Icons.calendar_today,
                size: 20, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
