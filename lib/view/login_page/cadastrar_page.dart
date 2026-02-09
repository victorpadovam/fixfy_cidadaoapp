import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:diacritic/diacritic.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixfycidadaoapp/controller/cadastro_controller.dart';
import 'package:fixfycidadaoapp/infra/api.dart';
import 'package:fixfycidadaoapp/models/estabelecimento/estabelecimento_model.dart';
import 'package:fixfycidadaoapp/view/login_page/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:http/http.dart' as http;
import '../componets/styles.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http_parser/http_parser.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  int _currentStep = 0;
  bool isLoadingImage = false;
  String? warningMessage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  final TextEditingController pincodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final TextEditingController cpfController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();

  final cepController = TextEditingController();
  final bairroController = TextEditingController();
  final ruaController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final zonaController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();

  final formKeyStep1 = GlobalKey<FormState>();

  bool isStep1Valid = false;

  bool isFetchingAddress = false;
  bool showAddressFields = false;

  File? selectedImage;

  List<Estabelecimento> estabelecimentos = [];
  bool isLoading = true;
  List<Estabelecimento> cidadesDisponiveisApi = [];
  Estabelecimento? cidadeSelecionada;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    nomeController.addListener(_validateStep1);
    senhaController.addListener(_validateStep1);
    emailController.addListener(_validateStep1);
    cpfController.addListener(_validateStep1);
    cepController.addListener(_updateStep2Validity);
    cidadeController.addListener(_updateStep2Validity);
    ruaController.addListener(_updateStep2Validity);
    bairroController.addListener(_updateStep2Validity);
    latitudeController.addListener(_updateStep2Validity);
    longitudeController.addListener(_updateStep2Validity);
    estadoController.addListener(_updateStep2Validity);

    fetchEstabelecimentos().then((list) {
      setState(() {
        estabelecimentos = list;
        cidadesDisponiveisApi = list;
        cidadesDisponiveisApi = list;
        isLoading = false;
      });
      ;
    });
  }

  void _updateStep2Validity() {
    setState(() {});
  }

  void _validateStep1() {
    final isValid = formKeyStep1.currentState?.validate() ?? false;
    if (isValid != isStep1Valid) {
      setState(() {
        isStep1Valid = isValid;
      });
    }
  }

  Future<void> fetchLatLongFromAddress(String cep, String logradouro,
      String bairro, String cidade, String uf) async {
    final cepClean = cep.replaceAll(RegExp(r'[^0-9]'), '');
    final query = '$logradouro, $bairro, $cidade, $uf, $cepClean, Brasil';

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
    );

    final response =
        await http.get(uri, headers: {'User-Agent': 'kyc-app/1.0'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data.isNotEmpty) {
        final lat = data[0]['lat'];
        final lon = data[0]['lon'];

        setState(() {
          latitudeController.text = lat.toString();
          longitudeController.text = lon.toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível obter localização.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao consultar coordenadas.')),
      );
    }
  }

  final List<String> zonas = [
    'Zona Sul',
    'Zona Norte',
    'Zona Leste',
    'Zona Oeste',
    'Zona Central',
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        isLoadingImage = true;
      });

      // Simula um tempo de carregamento
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        selectedImage = File(pickedFile.path);
        isLoadingImage = false;
      });
    }
  }

  Future<void> fetchAddressByCep(String cep) async {
    setState(() {
      isFetchingAddress = true;
      warningMessage = null; // limpa mensagem anterior
    });

    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$cleanCep/json/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['erro'] == true || data['erro'] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CEP não encontrado'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          showAddressFields = false;
          isFetchingAddress = false;
        });
      } else {
        final cidadeCep = (data['localidade'] ?? '').toLowerCase();
        final cidadeCepNormalized = removeDiacritics(cidadeCep);
        final cidadeSelecionadaNormalized =
            removeDiacritics(cidadeSelecionada!.cidade.toLowerCase());

        // Validação de cidade
        if (cidadeSelecionada != null &&
            cidadeCepNormalized != cidadeSelecionadaNormalized) {
          setState(() {
            warningMessage =
                'O CEP informado não pertence à cidade selecionada.';
            showAddressFields = false;
            isFetchingAddress = false; // <- CORREÇÃO ESSENCIAL AQUI
          });
          return;
        }

        // Preencher campos
        bairroController.text = data['bairro'] ?? '';
        ruaController.text = data['logradouro'] ?? '';
        complementoController.text = data['complemento'] ?? '';

        await fetchLatLongFromAddress(
          cepController.text,
          ruaController.text,
          bairroController.text,
          data['localidade'] ?? '',
          data['uf'] ?? '',
        );

        setState(() {
          warningMessage = null;
          showAddressFields = true;
          isFetchingAddress = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao buscar CEP'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isFetchingAddress = false;
      });
    }
  }

  String selectedDocType = 'Aadhar Card';
  String selectedAccountType = 'Savings';

  final List<String> docTypes = ['Aadhar Card', 'Pan Card', 'Driving License'];
  final List<String> accountTypes = ['Savings', 'Current'];

  Future<void> _nextStep() async {
    // Passo 0: exigir imagem
    if (_currentStep == 0 && selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil obrigatória'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Passo 1: validar formulário
    if (_currentStep == 1 && !formKeyStep1.currentState!.validate()) {
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Alterar estado para mostrar o loading no botão
      setState(() {
        isSubmitting = true;
      });

      try {
        // Chama a função de envio da API
        await enviarCidadaoParaApi();

        // Depois de finalizar a requisição, resetar o estado
        setState(() {
          isSubmitting = false;
        });
      } catch (e) {
        // Se ocorrer um erro na API, para o loading
        setState(() {
          isSubmitting = false;
        });

        // Exibe uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar os dados.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  bool isStep2Valid() {
    return cidadeSelecionada != null &&
        cepController.text.trim().isNotEmpty &&
        zonaController.text.trim().isNotEmpty &&
        ruaController.text.trim().isNotEmpty &&
        bairroController.text.trim().isNotEmpty &&
        latitudeController.text.trim().isNotEmpty &&
        longitudeController.text.trim().isNotEmpty;
  }

  Widget _stepIndicator(String label, int stepIndex) {
    final bool isActive = stepIndex == _currentStep;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: urbanist200.copyWith(
              color: isActive
                  ? Color(0xFF1E63F1)
                  : const Color.fromARGB(255, 4, 3, 3),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            color: isActive ? Color(0xFF1E63F1) : Colors.grey[300],
          )
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (isLoading) {
      return Lottie.asset(
        'assets/lottie/loading.json',
        width: 300,
        height: 200,
      );
    }

    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Foto de perfil 📷",
              style: urbanist500.copyWith(
                fontSize: 20,
              ),
            ),
            Text(
              "Sua foto será exibida no seu perfil e em interações dentro do app.",
              style: urbanist500.copyWith(
                fontSize: 14,
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Lottie animação por trás
                  SizedBox(
                    width: 370,
                    height: 370,
                    child: Lottie.asset(
                      'assets/lottie/avatar_circular.json',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Avatar circular
                  GestureDetector(
                    onTap: _pickImage,
                    child: DottedBorder(
                      color: Color(0xFF1E63F1),
                      borderType: BorderType.Circle,
                      dashPattern: const [8, 4],
                      strokeWidth: 2,
                      child: Container(
                        height: 190,
                        width: 190,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF8F8F8),
                        ),
                        child: isLoadingImage
                            ? Lottie.asset('assets/lottie/check_imagem.json')
                            : selectedImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                      width: 150,
                                      height: 150,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.image_outlined,
                                          size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        "Selecionar",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),

                  if (selectedImage != null)
                    Positioned(
                      bottom: 270,
                      right: 55,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Color(0xFF1E63F1),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        );

      case 1:
        return Form(
          key: formKeyStep1,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Identificação",
                style: urbanist500.copyWith(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nomeController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
                decoration: defaultInputDecoration("Nome Completo"),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: cpfController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CpfInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'CPF obrigatório';
                  return null;
                },
                decoration: defaultInputDecoration("CPF"),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Email obrigatório';
                  return null;
                },
                decoration: defaultInputDecoration("E-mail"),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              PasswordField(controller: senhaController),
              const SizedBox(height: 24),
              TextFormField(
                controller: telefoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneMaskFormatter],
                decoration: defaultInputDecoration("Telefone (opcional)"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );

      case 2:
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Endereço",
                style: urbanist500.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),

              // Dropdown de cidade
              DropdownSearch<Estabelecimento>(
                items: cidadesDisponiveisApi,
                selectedItem: cidadeSelecionada,
                itemAsString: (item) =>
                    '${item?.cidade ?? ''} - ${item?.estado ?? ''}',
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: defaultInputDecoration('Cidade *'),
                ),
                dropdownButtonProps: const DropdownButtonProps(
                  icon: Icon(Icons.keyboard_arrow_down),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  menuProps: const MenuProps(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1E63F1), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1E63F1), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1E63F1), width: 2),
                      ),
                    ),
                  ),
                  itemBuilder: (context, item, isSelected) {
                    return ListTile(
                      leading: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                      ),
                      title: Text(
                        '${item.cidade} - ${item.estado}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      dense: true,
                    );
                  },
                ),
                onChanged: (value) {
                  setState(() {
                    cidadeSelecionada = value;
                    cidadeController.text = value?.cidade ?? '';
                    estadoController.text = value?.estado ?? '';
                  });
                },
              ),

              const SizedBox(height: 24),

              // Exibir CEP só depois de selecionar cidade
              if (cidadeSelecionada != null) ...[
                TextFormField(
                  controller: cepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CepInputFormatter(),
                  ],
                  decoration: defaultInputDecoration('CEP'),
                  onChanged: (value) {
                    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');

                    if (warningMessage != null) {
                      setState(() {
                        warningMessage = null;
                      });
                    }

                    if (clean.length == 8) {
                      fetchAddressByCep(value);
                    } else {
                      setState(() {
                        showAddressFields = false;
                      });
                    }
                  },
                  validator: (value) {
                    final clean =
                        value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                    if (clean.length != 8) return 'CEP deve ter 8 dígitos';
                    if (!showAddressFields) {
                      return 'CEP inválido ou ainda não consultado';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              if (warningMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 230, 230, 230),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              warningMessage!,
                              style: urbanist500,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Se achar necessário, entre em contato com o suporte fixfysuporte@gmail.com',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Loading
              if (isFetchingAddress)
                Center(
                  child: Lottie.asset(
                    'assets/lottie/loading.json',
                    width: 100,
                    height: 100,
                  ),
                ),

              // Campos adicionais
              if (showAddressFields) ...[
                TextFormField(
                  controller: ruaController,
                  decoration: defaultInputDecoration('Rua'),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: bairroController,
                  decoration: defaultInputDecoration('Bairro'),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: numeroController,
                  decoration: defaultInputDecoration('Número'),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: zonaController.text.isNotEmpty
                      ? zonaController.text
                      : null,
                  items: zonas.map((zona) {
                    return DropdownMenuItem<String>(
                      value: zona,
                      child: Text(zona),
                    );
                  }).toList(),
                  decoration: defaultInputDecoration('Zona'),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        zonaController.text = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: estadoController,
                  enabled: false,
                  style: TextStyle(color: Colors.grey[600]),
                  decoration: defaultInputDecoration('Estado').copyWith(
                    filled: true,
                    fillColor: Colors.grey[300],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: latitudeController,
                  enabled: false,
                  style: TextStyle(color: Colors.grey[600]),
                  decoration: defaultInputDecoration('Latitude').copyWith(
                    filled: true,
                    fillColor: Colors.grey[300],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: longitudeController,
                  enabled: false,
                  style: TextStyle(color: Colors.grey[600]),
                  decoration: defaultInputDecoration('Longitude').copyWith(
                    filled: true,
                    fillColor: Colors.grey[300],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro',
          style: urbanist500,
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 70,
            child: Container(
              color: Color.fromARGB(255, 250, 250, 250),
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: 8,
              ),
              child: Row(
                children: [
                  _stepIndicator("Foto de perfil", 0),
                  _stepIndicator("Identificação", 1),
                  _stepIndicator("Endereço", 2),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 250, 250, 250),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: _buildStepContent(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 29, 65),
                      child: SizedBox(
                        height: 64,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (_currentStep > 0)
                              IconButton(
                                onPressed: _previousStep,
                                icon: const Icon(Icons.arrow_back),
                                iconSize: 28,
                                tooltip: 'Voltar',
                              ),
                            if (_currentStep > 0) const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isButtonEnabled() ? _nextStep : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isButtonEnabled()
                                      ? const Color(0xFF1E63F1)
                                      : Colors.grey,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _currentStep < 2
                                            ? "CONTINUAR"
                                            : "FINALIZAR",
                                        style: urbanist500.copyWith(
                                            color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isButtonEnabled() {
    switch (_currentStep) {
      case 0:
        return !isLoadingImage && selectedImage != null;
      case 1:
        return isStep1Valid;
      case 2:
        return isStep2Valid();
      default:
        return false;
    }
  }

  Future<String?> uploadImagemParaCloudflare(File imageFile) async {
    // 1. Comprimir a imagem (retorna bytes)
    final Uint8List? compressedBytes =
        await FlutterImageCompress.compressWithFile(
      imageFile.path,
      quality: 75, // ajusta a qualidade conforme necessário
      format: CompressFormat.jpeg,
      minWidth: 800, // opcional
      minHeight: 600, // opcional
    );

    if (compressedBytes == null) {
      print('Erro ao comprimir imagem');
      return null;
    }

    // 2. Criar MultipartFile a partir dos bytes
    final multipartFile = http.MultipartFile.fromBytes(
      'image', // nome do campo no form
      compressedBytes,
      filename: 'upload.jpg',
      contentType: MediaType('image', 'jpeg'), // opcional mas recomendável
    );

    // 3. Criar e enviar a requisição
    final uri = Uri.parse(urlServer + '/uploadImagem/upload-imagem-cloudflare');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decoded = jsonDecode(responseBody);
      return decoded['data']['urlPublica'];
    } else {
      print('Erro no upload da imagem: ${response.statusCode}');
      return null;
    }
  }

  Future<void> enviarCidadaoParaApi() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // 🔑 Token FCM
    final token = await messaging.getToken();

    print('🔑 Token FCM: $token');

    String? fotoUrl;

    if (selectedImage != null) {
      fotoUrl = await uploadImagemParaCloudflare(selectedImage!);
      if (fotoUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao fazer upload da imagem')),
        );
        return;
      }
    }

    final uri = Uri.parse(urlServer + '/cidadaos');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'nome': nomeController.text,
        'foto': fotoUrl ?? '',
        'email': emailController.text,
        'cpf': cpfController.text,
        'telefone': telefoneController.text,
        'cidade': cidadeController.text,
        'estado': estadoController.text,
        'token_fcm_firebase': token,
        'estabelecimento_id': cidadeSelecionada!.id,
        'zona': zonaController.text,
        'bairro': bairroController.text,
        'rua': ruaController.text,
        'numero': numeroController.text,
        'complemento': complementoController.text,
        'cep': cepController.text,
        'ponto_referencia': "",
        'latitude': latitudeController.text,
        'longitude': longitudeController.text,
        'senha': senhaController.text,
        'codigo_ibge_cidade': '',
      }),
    );

    if (response.statusCode == 200) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuccessScreen()),
        );
      });
    } else {
      print('Erro ao salvar cidadão: ${response.body}');
      final decoded = jsonDecode(response.body);
      final errorMessage = decoded['message'] ?? 'Erro desconhecido';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $errorMessage')),
      );
    }
  }
}

InputDecoration defaultInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey[600]),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1E63F1), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
    floatingLabelStyle: const TextStyle(color: Color(0xFF1E63F1)),
  );
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  double _strength = 0;
  String _strengthLabel = "";
  Color _strengthColor = Colors.transparent;
  bool _showStrength = false;

  void _checkPasswordStrength(String password) {
    double strength = 0;

    if (password.isEmpty) {
      setState(() {
        _showStrength = false;
      });
      return;
    }

    _showStrength = true;

    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9!@#\$&*~]').hasMatch(password)) strength += 0.25;

    String label;
    Color color;

    if (strength <= 0.25) {
      label = "Fraca";
      color = Colors.red;
    } else if (strength <= 0.5) {
      label = "Média";
      color = Colors.orange;
    } else if (strength < 1) {
      label = "Boa";
      color = Colors.lightGreen;
    } else {
      label = "Forte";
      color = Colors.green;
    }

    setState(() {
      _strength = strength;
      _strengthLabel = label;
      _strengthColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.visiblePassword,
          obscureText: _obscureText,
          onChanged: _checkPasswordStrength,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Obrigatório';
            return null;
          },
          decoration: defaultInputDecoration("Senha").copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        if (_showStrength) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _strength,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Senha $_strengthLabel',
                  style: TextStyle(
                    color: _strengthColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
