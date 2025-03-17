import 'package:intl/intl.dart';

String converterDataEHoras(String input,
    {String formato = 'dd/MM/yyyy HH:mm'}) {
  try {
    DateTime dataHora = DateTime.parse(input);
    return DateFormat(formato).format(dataHora);
  } catch (e) {
    try {
      DateTime hora = DateFormat('HH:mm').parse(input);
      return DateFormat(formato)
          .format(DateTime(0, 1, 1, hora.hour, hora.minute));
    } catch (e) {
      return 'Formato inválido!';
    }
  }
}
