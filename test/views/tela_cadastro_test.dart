// test/views/tela_cadastro_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:projeto_integrador2/views/tela_cadastro.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';

// A classe MockAuthViewModel é esperada de um arquivo de mock gerado.
// O outro arquivo de teste do usuário usa uma importação semelhante.
import '../mocks/login.mocks.mocks.dart';

void main() {
  late MockAuthViewModel mockAuthViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    // Define um status padrão para evitar problemas de nulo na primeira construção
    when(mockAuthViewModel.status).thenReturn(AuthStatus.unauthenticated);
    // Sucesso padrão para chamadas signUp, a menos que especificado de outra forma em um teste
    when(mockAuthViewModel.signUp(any, any)).thenAnswer((_) async => true);
  });

  // Função auxiliar para renderizar o widget com o provider necessário
  Future<void> _pumpTelaCadastro(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: mockAuthViewModel,
        child: const MaterialApp(
          home: TelaCadastro(),
        ),
      ),
    );
  }

  group('TelaCadastro Widget Tests', () {
    testWidgets('deve mostrar erros de validação para campos vazios e senhas que não coincidem', (tester) async {
      // Arrange
      await _pumpTelaCadastro(tester);

      // Act 1: Tenta submeter com todos os campos vazios
      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
      await tester.pumpAndSettle(); // pumpAndSettle para aguardar as animações de validação

      // Assert 1: Verifica as mensagens de erro para campos vazios
      expect(find.text('Por favor, insira seu e-mail.'), findsOneWidget);
      expect(find.text('Por favor, insira uma senha.'), findsOneWidget);
      expect(find.text('Por favor, confirme sua senha.'), findsOneWidget);

      // Act 2: Preenche o e-mail e as senhas de forma que não coincidam
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'teste@teste.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirme a Senha'), '654321');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
      await tester.pumpAndSettle();

      // Assert 2: Verifica se a mensagem de erro de senhas não coincidentes é exibida
      expect(find.text('As senhas não coincidem.'), findsOneWidget);
      // A mensagem de confirmação de senha não deve estar mais visível
      expect(find.text('Por favor, confirme sua senha.'), findsNothing);
    });

    testWidgets('deve chamar o método signUp no AuthViewModel ao clicar em Cadastrar', (tester) async {
      // Arrange
      await _pumpTelaCadastro(tester);

      const email = 'novo.usuario@teste.com';
      const password = 'senha_super_segura';

      // Act: Preenche o formulário com dados válidos
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), email);
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), password);
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirme a Senha'), password);

      // Toca no botão de cadastrar
      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
      await tester.pump(); // Pump para processar o clique

      // Assert: Verifica se o método signUp foi chamado com os dados corretos
      verify(mockAuthViewModel.signUp(email, password)).called(1);
    });
  });
}
