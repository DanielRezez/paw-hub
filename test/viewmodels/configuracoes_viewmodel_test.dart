import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importe os ViewModels
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:projeto_integrador2/viewmodels/configuracoes_viewmodel.dart';

// Importe os mocks que vamos gerar
import 'configuracoes_viewmodel_test.mocks.dart';

// 1. Diga ao Mockito para gerar dublês do AuthViewModel e SharedPreferences
@GenerateMocks([AuthViewModel, SharedPreferences])
void main() {
  // 2. Declare as variáveis
  late ConfiguracoesViewModel viewModel;
  late MockAuthViewModel mockAuthViewModel;

  // 3. 'setUp' (preparação) antes de cada teste
  setUp(() {
    // Cria um dublê limpo do AuthViewModel
    mockAuthViewModel = MockAuthViewModel();

    // Cria o ViewModel "de verdade", mas injeta o dublê do Auth
    viewModel = ConfiguracoesViewModel(mockAuthViewModel);

    // Garante que o ambiente de teste do Flutter está pronto
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  // --- TAREFA: Testar o método toggleNotifications ---
  test('toggleNotifications deve atualizar a propriedade e salvar no SharedPreferences', () async {
    // PREPARAÇÃO (Arrange)
    // Limpa o "disco falso" e define valores iniciais
    SharedPreferences.setMockInitialValues({});
    // Carrega as preferências (inicia com o valor padrão 'true')
    await viewModel.loadPreferences();

    // Garante que o valor inicial é 'true'
    expect(viewModel.notificationsEnabled, true);

    // AÇÃO (Act)
    // Desativa as notificações
    await viewModel.toggleNotifications(false);

    // VERIFICAÇÃO (Assert)
    // 1. Verifica se a propriedade no ViewModel mudou
    expect(viewModel.notificationsEnabled, false);

    // 2. Verifica se foi salvo no "disco falso"
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(kNotificationsEnabledPrefKey), false);
  });

  // --- TAREFA: Testar o método logout ---
  test('logout deve chamar signOutAll no AuthViewModel', () async {
    // PREPARAÇÃO
    // (O mockAuthViewModel já foi injetado pelo setUp)

    // AÇÃO
    await viewModel.logout();

    // VERIFICAÇÃO
    // Verifica se o método 'signOutAll' do dublê
    // (mockAuthViewModel) foi chamado exatamente 1 vez.
    verify(mockAuthViewModel.signOutAll()).called(1);
  });
}