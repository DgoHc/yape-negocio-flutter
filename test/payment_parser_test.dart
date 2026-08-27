import 'package:flutter_test/flutter_test.dart';
import 'package:sonopay/features/notifications/domain/parsers/payment_parser.dart';

void main() {
  group('PaymentParser Unit Tests', () {
    test('Debe parsear correctamente un pago con espacio entre S/ y monto y texto extra (caso log REAL)', () {
      const raw = 'Emilia Car* te envió un pago por S/ 0.1. El cód. de seguridad es: 569';
      final result = PaymentParser.parse(raw);
      
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.senderName, 'Emilia Car');
          expect(r.amount, 0.1);
          expect(r.currency, 'S/');
        },
      );
    });

    test('Debe parsear correctamente un pago con espacio entre S/ y monto (caso log)', () {
      const raw = 'Emilia Car* te envió un pago por S/ 0.1';
      final result = PaymentParser.parse(raw);
      
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.senderName, 'Emilia Car');
          expect(r.amount, 0.1);
          expect(r.currency, 'S/');
        },
      );
    });

    test('Debe parsear correctamente un pago estándar con asterisco', () {
      const raw = 'Juan Pérez* te envió un pago por S/2.50';
      final result = PaymentParser.parse(raw);
      
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.senderName, 'Juan Pérez');
          expect(r.amount, 2.50);
          expect(r.currency, 'S/');
        },
      );
    });

    test('Debe parsear correctamente un pago sin asterisco', () {
      const raw = 'María López te envió un pago por S/1.00';
      final result = PaymentParser.parse(raw);
      
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.senderName, 'María López');
          expect(r.amount, 1.00);
        },
      );
    });

    test('Debe parsear montos con prefijo PEN', () {
      const raw = 'Pedro te envió un pago por PEN 10.00';
      final result = PaymentParser.parse(raw);
      
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) {
          expect(r.currency, 'PEN');
          expect(r.amount, 10.00);
        },
      );
    });

    test('Debe soportar montos enteros', () {
      const raw = 'Carlos te envió un pago por S/50';
      final result = PaymentParser.parse(raw);
      
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('No debería fallar'),
        (r) => expect(r.amount, 50.0),
      );
    });

    test('Debe fallar con texto inválido', () {
      const raw = 'Esto no es un pago de Yape';
      final result = PaymentParser.parse(raw);
      expect(result.isLeft(), true);
    });

    test('Debe fallar con texto vacío', () {
      const raw = '';
      final result = PaymentParser.parse(raw);
      expect(result.isLeft(), true);
    });

    test('Debe fallar si el monto es cero', () {
      const raw = 'Juan te envió un pago por S/0.00';
      final result = PaymentParser.parse(raw);
      expect(result.isLeft(), true);
    });

    test('Debe manejar espacios extra', () {
      const raw = '  Lucia   te envió un pago por S/ 5.50  ';
      final result = PaymentParser.parse(raw.trim());
      expect(result.isRight(), true);
      result.fold((l) => null, (r) => expect(r.senderName, 'Lucia'));
    });

    test('Debe fallar si falta el nombre', () {
      const raw = 'te envió un pago por S/10.00';
      final result = PaymentParser.parse(raw);
      expect(result.isLeft(), true);
    });

    test('Debe parsear nombres con múltiples palabras', () {
      const raw = 'Centro Comercial Jockey Plaza* te envió un pago por S/100.00';
      final result = PaymentParser.parse(raw);
      expect(result.isRight(), true);
      result.fold((l) => null, (r) => expect(r.senderName, 'Centro Comercial Jockey Plaza'));
    });
  });
}
