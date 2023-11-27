// ignore_for_file: no_leading_underscores_for_local_identifiers

library suitability_modal;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class SuitabilityModal extends StatefulWidget {
  final Color primaryColor;
  final List<Sections> suitabilityQuestions;
  final Future<void> Function(Map<String, dynamic> formData) apiCallFunction;
  final Future<void> Function()? onCloseFunction;
  final String? pathImageConfig;
  final ShareIcons shareIcons;
  final bool readOnly;

  const SuitabilityModal({
    Key? key,
    required this.primaryColor,
    required this.suitabilityQuestions,
    required this.apiCallFunction,
    this.pathImageConfig,
    this.onCloseFunction,
    this.shareIcons = const ShareIcons(),
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<SuitabilityModal> createState() => _SuitabilityModalState();
}

class _SuitabilityModalState extends State<SuitabilityModal> {
  OverlayEntry? overlayEntry;
  double _currentSliderValue = 25;
  final String suitabilityProfile = 'CONSERVADOR';
  final String suitabilityProfileMsg = 'Para você, segurança vem em primeiro lugar. Sua prioridade é não correr risco, mesmo que seu potencial de ganho seja um pouco menor';
  bool loading = false;
  bool goToNextPage = false;
  bool resultSuitabilityPage = false;
  var _localSuitabilityQuestions = <Sections>[];
  late ValueNotifier<bool> updateGoToNextPage;
  late ValueNotifier<int> pageSelected;
  late Sections sectionSelected;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    _localSuitabilityQuestions = widget.suitabilityQuestions
        .map((question) => question.deepCopy()) // Usa o método deepCopy
        .toList();

    pageSelected = ValueNotifier(0);
    updateGoToNextPage = ValueNotifier(false);
    scrollController = ScrollController();
    sectionSelected = _localSuitabilityQuestions[pageSelected.value];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay(context);

      pageSelected.addListener(() {
        sectionSelected = _localSuitabilityQuestions[pageSelected.value];
        overlayEntry?.markNeedsBuild();
      });
    });
  }

  void _showOverlay(BuildContext context) {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.only(left: 150.0, right: 150, top: 40, bottom: 100),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth < 800 ? 800 : constraints.maxWidth;

                  return Material(
                    color: Colors.white,
                    elevation: 10,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: loading ? 600 : width,
                      child: loading
                          ? Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: widget.primaryColor.withOpacity(0.05)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 120.0),
                                child: LoadingImageWidget(
                                  primaryColor: widget.primaryColor,
                                  pathImageConfig: widget.pathImageConfig,
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                if (resultSuitabilityPage) ...[
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: PackageColors.whiteSmoke,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20), // Defina o raio para o canto superior esquerdo
                                        topRight: Radius.circular(20), // Defina o raio para o canto superior direito
                                      ),
                                    ),
                                    height: 280,
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 50, right: 50),
                                      child: InkWell(
                                        hoverColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        mouseCursor: SystemMouseCursors.click,
                                        child: const Icon(
                                          Icons.close,
                                          color: PackageColors.fiord,
                                          size: 36,
                                        ),
                                        onTap: () => _removeDialog(overlayEntry),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 48),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'O SEU PERFIL É',
                                              style: TextStyle(color: PackageColors.blueBayoux, fontSize: 22),
                                            ),
                                            const SizedBox(height: 16),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                color: widget.primaryColor.withOpacity(0.25),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                                              child: Text(
                                                suitabilityProfile.toUpperCase(),
                                                style: TextStyle(color: widget.primaryColor, fontSize: 32, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 100.0),
                                              child: Text(
                                                suitabilityProfileMsg,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: PackageColors.blueBayoux, fontSize: 16),
                                              ),
                                            ),
                                            const SizedBox(height: 96),
                                            const Text(
                                              'Produtos que combinam com seu perfil',
                                              style: TextStyle(color: PackageColors.blueBayoux, fontSize: 24),
                                            ),
                                            const SizedBox(height: 24),
                                            Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    const Spacer(flex: 4),
                                                    ProductsWidget(
                                                      primaryColor: widget.primaryColor,
                                                      updateGoToNextPage: updateGoToNextPage,
                                                      goToNextPage: goToNextPage,
                                                    ),
                                                    const Spacer(),
                                                    ProductsWidget(
                                                      primaryColor: widget.primaryColor,
                                                      updateGoToNextPage: updateGoToNextPage,
                                                      goToNextPage: goToNextPage,
                                                    ),
                                                    const Spacer(),
                                                    ProductsWidget(
                                                      primaryColor: widget.primaryColor,
                                                      updateGoToNextPage: updateGoToNextPage,
                                                      goToNextPage: goToNextPage,
                                                    ),
                                                    const Spacer(),
                                                    ProductsWidget(
                                                      primaryColor: widget.primaryColor,
                                                      updateGoToNextPage: updateGoToNextPage,
                                                      goToNextPage: goToNextPage,
                                                    ),
                                                    const Spacer(flex: 4),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 40),
                                            const Divider(color: PackageColors.whiteSmoke75),
                                            const SizedBox(height: 32),
                                            const Text(
                                              'COMPARTILHAR PERFIL DE INVESTIR',
                                              style: TextStyle(color: PackageColors.brightGrey, fontSize: 12),
                                            ),
                                            const SizedBox(height: 40),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: List.generate(
                                                3,
                                                (index) => Row(
                                                  children: [
                                                    ShareButton(
                                                      icon: widget.shareIcons.getIcons[index],
                                                      label: widget.shareIcons.getLabels[index],
                                                      path: widget.shareIcons.getPaths[index],
                                                      primaryColor: widget.primaryColor,
                                                      onTap: widget.shareIcons.functions[index],
                                                    ),
                                                    const SizedBox(width: 24)
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: widget.primaryColor.withOpacity(0.25),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(20), // Defina o raio para o canto superior esquerdo
                                            bottomRight: Radius.circular(20), // Defina o raio para o canto superior direito
                                          ),
                                        ),
                                        height: 105,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SuitabilityButton(
                                              primaryColor: widget.primaryColor,
                                              label: 'REFAZER O TESTE DE PERFIL',
                                              onTap: () {
                                                _localSuitabilityQuestions = widget.suitabilityQuestions
                                                    .map((question) => question.deepCopy()) // Usa o método deepCopy
                                                    .toList();

                                                pageSelected.value = 0;
                                                updateGoToNextPage.value = false;
                                                goToNextPage = false;
                                                resultSuitabilityPage = false;
                                                loading = false;

                                                sectionSelected = _localSuitabilityQuestions[pageSelected.value];

                                                overlayEntry?.markNeedsBuild();
                                              },
                                            ),
                                            const SizedBox(width: 24),
                                            SuitabilityButton(
                                              primaryColor: widget.primaryColor,
                                              alternativeButton: true,
                                              label: 'FALAR COM GERENTE',
                                              onTap: () {},
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ] else ...[
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: PackageColors.whiteSmoke,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20), // Defina o raio para o canto superior esquerdo
                                        topRight: Radius.circular(20), // Defina o raio para o canto superior direito
                                      ),
                                    ),
                                    height: 310,
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 48),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ..._header(),
                                            ...questionsBuilder(),
                                          ],
                                        ),
                                      ),
                                      _footer(),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(overlayEntry!);
  }

  void scrollToTop() {
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  bool _checkerNextPage() {
    for (var question in sectionSelected.questions) {
      bool haveAnswer = false;

      for (var answer in question.answers) {
        if (answer.selected == true) {
          haveAnswer = true;
        }
      }

      if (!haveAnswer) {
        if (question.layoutDesign == LayoutDesign.slider) {
          question.answers.first.selected = true;
        } else {
          return false;
        }
      }
    }
    return true;
  }

  Widget _footer() {
    return Container(
      decoration: BoxDecoration(
        color: widget.primaryColor.withOpacity(0.25),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20), // Defina o raio para o canto superior esquerdo
          bottomRight: Radius.circular(20), // Defina o raio para o canto superior direito
        ),
      ),
      height: 105,
      child: Center(
          child: SuitabilityButton(
        primaryColor: widget.primaryColor,
        label: pageSelected.value != _localSuitabilityQuestions.length - 1 ? 'CONTINUAR' : 'VERIFICAR PERFIL DE INVESTIDOR',
        onTap: () async {
          if (_checkerNextPage() && pageSelected.value < _localSuitabilityQuestions.length) {
            final maxPages = _localSuitabilityQuestions.length;

            if (pageSelected.value < maxPages && pageSelected.value != maxPages) {
              goToNextPage = true;
              updateGoToNextPage.value = !updateGoToNextPage.value;

              pageSelected.value++;

              scrollToTop();

              _currentSliderValue = 20;
              goToNextPage = false;
              updateGoToNextPage.value = !updateGoToNextPage.value;

              overlayEntry?.markNeedsBuild();
            }
            if (pageSelected.value == maxPages) {
              final map = <String, dynamic>{
                'formData': <String, dynamic>{
                  'sections': _localSuitabilityQuestions.map((question) => question.toJson()).toList(),
                }
              };

              try {
                loading = true;
                overlayEntry?.markNeedsBuild();

                Future.delayed(const Duration(seconds: 5), () async {
                  await widget.apiCallFunction(map).then(
                    (value) {
                      loading = false;
                      resultSuitabilityPage = true;
                      overlayEntry?.markNeedsBuild();
                    },
                  );
                });
              } catch (error) {
                debugPrint('error on call api in suitability modal => ${error.toString()}');
              }
            }
          } else {
            goToNextPage = false;
            updateGoToNextPage.value = !updateGoToNextPage.value;
          }
        },
      )),
    );
  }

  List<Widget> _header() {
    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('DEFINIR PERFIL DE INVESTIDOR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.primaryColor)),
        InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          mouseCursor: SystemMouseCursors.click,
          child: const Icon(
            Icons.close,
            color: PackageColors.fiord,
            size: 36,
          ),
          onTap: () {
            _removeDialog(overlayEntry);

            widget.onCloseFunction?.call();
          },
        )
      ]),
      const SizedBox(height: 50),
      const Text(
          '''Para fazer bons investimentos é fundamental saber qual é o seu perfil de investidor. Com base nessas informações, podemos te auxiliar na escolha dos produtos ideais para você. E para descobri-lá, vamos te fazer algumas perguntas.''',
          style: TextStyle(fontSize: 18, color: PackageColors.brightGrey)),
      const SizedBox(height: 50),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sectionSelected.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: PackageColors.blueBayoux),
          ),
          bars(pageSelected: pageSelected.value),
        ],
      ),
      const SizedBox(height: 32)
    ];
  }

  List<Widget> questionsBuilder() {
    final res = <Widget>[];
    final pageQuestions = sectionSelected.questions;

    for (var i = 0; i < pageQuestions.length; i++) {
      res.add(questionWidgetBuild(
        index: i,
        question: pageQuestions[i].name,
        answer: pageQuestions[i].answers,
        questionLayout: pageQuestions[i].layoutDesign,
        isLast: i < pageQuestions.length - 1,
      ));
    }

    return res;
  }

  Widget questionWidgetBuild({
    required LayoutDesign questionLayout,
    required int index,
    required String question,
    required List<Answers> answer,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pergunta ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: PackageColors.brightGrey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          SizedBox(child: Text(question, style: const TextStyle(color: PackageColors.brightGrey, fontSize: 16))),
          if (questionLayout == LayoutDesign.slider) ...[
            const SizedBox(height: 36),
            CustomSlider(
              primaryColor: widget.primaryColor,
              value: _currentSliderValue,
              divisions: 4, // Número de divisões do Slider
              labels: answer.map((item) => item.name).toList(), // Labels para os separadores
              onChanged: (double value) async {
                if (value >= 20) {
                  _currentSliderValue = value;
                  var index = 0;

                  if (value <= 25) index = 0;
                  if (value > 25 && value <= 50) index = 1;
                  if (value > 50 && value <= 75) index = 2;
                  if (value > 75) index = 3;

                  for (var item in answer) {
                    item.selected = false;
                  }

                  answer[index].selected = true;

                  overlayEntry?.markNeedsBuild();
                }
              },
            )
          ] else ...[
            Column(
              children: [
                const SizedBox(height: 16),
                CustomRadioButton(
                  answers: answer,
                  primaryColor: widget.primaryColor,
                  onTap: () {
                    overlayEntry?.markNeedsBuild();
                  },
                )
              ],
            )
          ],
          SizedBox(height: !isLast ? 0 : 32),
          if (isLast)
            const Divider(
              color: PackageColors.whiteSmoke25,
            ),
        ],
      ),
    );
  }

  Widget bars({required int pageSelected}) {
    final maxPages = _localSuitabilityQuestions.length;

    final percentPage = 3 / maxPages;

    final percent = percentPage * (pageSelected + 1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _bar(pageSelected == 0
            ? 0.15
            : percent > 1
                ? 1
                : percent),
        const SizedBox(width: 10),
        _bar(percent > 1 && percent <= 2
            ? percent - 1 == 1
                ? 0.85
                : percent - 1
            : percent <= 1
                ? 0
                : 1),
        const SizedBox(width: 10),
        _bar(percent > 2
            ? percent - 2 == 1
                ? 0.75
                : percent - 2
            : 0)
      ],
    );
  }

  SizedBox _bar(double percent) {
    return SizedBox(
      width: 108,
      child: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5), // Ajuste o raio conforme necessário
          child: LinearProgressIndicator(
            color: widget.primaryColor,
            backgroundColor: PackageColors.gainsboro,
            value: percent,
          ),
        ),
      ),
    );
  }

  void _removeDialog(OverlayEntry? overlayEntry) {
    overlayEntry?.remove();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

///
///
///

class SuitabilityModalEditable extends StatefulWidget {
  final Color primaryColor;
  final List<Sections> suitabilityQuestions;
  final Future<void> Function(Map<String, dynamic> formData) apiCallFunction;
  final Future<void> Function()? onCloseFunction;
  final String? pathImageConfig;
  final ShareIcons shareIcons;

  const SuitabilityModalEditable({
    Key? key,
    required this.primaryColor,
    required this.suitabilityQuestions,
    required this.apiCallFunction,
    this.onCloseFunction,
    this.shareIcons = const ShareIcons(),
    this.pathImageConfig,
  }) : super(key: key);

  @override
  State<SuitabilityModalEditable> createState() => _SuitabilityModalEditableState();
}

class _SuitabilityModalEditableState extends State<SuitabilityModalEditable> {
  OverlayEntry? overlayEntry;
  OverlayEntry? overlayEntryNewQuestion;
  OverlayEntry? overlayEntryConfirm;

  final String suitabilityProfile = 'CONSERVADOR';
  final String suitabilityProfileMsg = 'Para você, segurança vem em primeiro lugar. Sua prioridade é não correr risco, mesmo que seu potencial de ganho seja um pouco menor';
  final String errorMsg = 'Você não pode prosseguir com as perguntas e/ou título de seção com nome padrão';

  bool loading = false;
  bool resultSuitabilityPage = false;
  bool error = true;

  var _localSuitabilityQuestions = <Sections>[];

  late ValueNotifier<int> pageSelected;
  late Sections sectionSelected;

  late ScrollController scrollController;
  late TextEditingController _sectionNameController;

  @override
  void initState() {
    super.initState();

    if (widget.suitabilityQuestions.isEmpty) {
      _localSuitabilityQuestions.add(Sections(
        name: 'Nova Seção ${_localSuitabilityQuestions.length + 1}',
        questions: [
          Question(
            name: 'Exemplo Pergunta 1',
            answers: [
              Answers(name: 'Exemplo resposta 1', selected: false),
              Answers(name: 'Exemplo resposta 2', selected: false),
              Answers(name: 'Exemplo resposta 3', selected: false),
              Answers(name: 'Exemplo resposta 4', selected: false)
            ],
            layoutDesign: LayoutDesign.multipleChoice,
          )
        ],
      ));
    } else {
      _localSuitabilityQuestions = widget.suitabilityQuestions
          .map((question) => question.deepCopy()) // Usa o método deepCopy
          .toList();
    }

    pageSelected = ValueNotifier(0);
    scrollController = ScrollController();
    sectionSelected = _localSuitabilityQuestions[pageSelected.value];
    _sectionNameController = TextEditingController(text: _localSuitabilityQuestions[pageSelected.value].name);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay(context);

      pageSelected.addListener(() {
        sectionSelected = _localSuitabilityQuestions[pageSelected.value];
        _sectionNameController = TextEditingController(text: _localSuitabilityQuestions[pageSelected.value].name);

        overlayEntry?.markNeedsBuild();
      });
    });
  }

  void _showOverlay(BuildContext context) {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.only(left: 150.0, right: 150, top: 40, bottom: 100),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth < 800 ? 800 : constraints.maxWidth;

                  return Material(
                    color: Colors.white,
                    elevation: 10,
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: loading ? 600 : width,
                      child: loading
                          ? Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: widget.primaryColor.withOpacity(0.05)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 120.0),
                                child: LoadingImageWidget(
                                  primaryColor: widget.primaryColor,
                                  pathImageConfig: widget.pathImageConfig,
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                if (resultSuitabilityPage)
                                  ...[]
                                else ...[
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: PackageColors.whiteSmoke,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20), // Defina o raio para o canto superior esquerdo
                                        topRight: Radius.circular(20), // Defina o raio para o canto superior direito
                                      ),
                                    ),
                                    height: 310,
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 48),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ..._header(),
                                            ...questionsBuilder(),
                                          ],
                                        ),
                                      ),
                                      _footer(),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(overlayEntry!);
  }

  void _showOverlayNewQuestion(
    BuildContext context, {
    Question? question,
    int? index,
  }) {
    final _answerType = [
      Answers(name: 'Slider'),
      Answers(name: 'Múltipla escolha'),
    ];

    final _questionController = TextEditingController(text: '');

    List<TextEditingController> _answerControllers = [
      TextEditingController(text: ''),
      TextEditingController(text: ''),
      TextEditingController(text: ''),
      TextEditingController(text: '')
    ];

    final _errorController = ValueNotifier(false);

    if (question != null) {
      if (question.layoutDesign == LayoutDesign.slider) {
        _answerType.first.selected = true;
      } else {
        _answerType.last.selected = true;
      }

      _questionController.text = question.name;

      for (var i = 0; i < _answerControllers.length; i++) {
        _answerControllers[i].text = question.answers[i].name;
      }
    }

    overlayEntryNewQuestion = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Padding(
          padding: const EdgeInsets.only(left: 380, right: 380, top: 40),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth < 450 ? 450 : constraints.maxWidth;

                return Material(
                  color: Colors.white,
                  elevation: 10,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                    width: width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Nova Pergunta',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: PackageColors.blueBayoux),
                            ),
                            const Spacer(),
                            InkWell(
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              mouseCursor: SystemMouseCursors.click,
                              child: const Icon(
                                Icons.close,
                                color: PackageColors.fiord,
                                size: 36,
                              ),
                              onTap: () {
                                for (var item in _answerControllers) {
                                  item.dispose();
                                }
                                _questionController.dispose();
                                _errorController.dispose();

                                _removeDialog(overlayEntryNewQuestion);
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          color: PackageColors.whiteSmoke50,
                        ),
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Selecione o tipo da pergunta: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: PackageColors.blueBayoux),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomRadioButton(
                          answers: _answerType,
                          primaryColor: widget.primaryColor,
                          onTap: () {
                            overlayEntryNewQuestion?.markNeedsBuild();
                          },
                          alternative: true,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: InputSuitability(
                                controller: _questionController,
                                overlay: overlayEntryNewQuestion,
                                hintText: 'Digite a pergunta',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 20,
                              child: InputSuitability(
                                controller: _answerControllers[0],
                                overlay: overlayEntryNewQuestion,
                                hintText: 'Digite a opção de resposta 1',
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              flex: 20,
                              child: InputSuitability(
                                controller: _answerControllers[1],
                                overlay: overlayEntryNewQuestion,
                                hintText: 'Digite a opção de resposta 2',
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 20,
                              child: InputSuitability(
                                controller: _answerControllers[2],
                                overlay: overlayEntryNewQuestion,
                                hintText: 'Digite a opção de resposta 3',
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              flex: 20,
                              child: InputSuitability(
                                controller: _answerControllers[3],
                                overlay: overlayEntryNewQuestion,
                                hintText: 'Digite a opção de resposta 4',
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 34),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SuitabilityButton(
                              primaryColor: widget.primaryColor,
                              label: 'Salvar',
                              onTap: () {
                                if (_checkerNewQuestionInputs(_answerControllers, _answerType) && _questionController.text != '') {
                                  late LayoutDesign _questionLayout;

                                  for (var item in _answerType) {
                                    if (item.selected) {
                                      if (item.name == 'Slider') {
                                        _questionLayout = LayoutDesign.slider;
                                      } else {
                                        _questionLayout = LayoutDesign.multipleChoice;
                                      }
                                    }
                                  }

                                  if (question != null) {
                                    question.name = _questionController.text;
                                    question.answers
                                      ..clear()
                                      ..addAll(_answerControllers.map((e) => Answers(name: e.text)).toList());
                                    question.layoutDesign = _questionLayout;
                                  } else {
                                    _localSuitabilityQuestions[pageSelected.value].questions.add(
                                          Question(
                                            name: _questionController.text,
                                            answers: _answerControllers.map((e) => Answers(name: e.text)).toList(),
                                            layoutDesign: _questionLayout,
                                          ),
                                        );
                                  }

                                  _removeDialog(overlayEntryNewQuestion);

                                  for (var item in _answerControllers) {
                                    item.dispose();
                                  }
                                  _questionController.dispose();
                                  _errorController.dispose();

                                  overlayEntry?.markNeedsBuild();
                                } else {
                                  _errorController.value = !_errorController.value;
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(overlayEntryNewQuestion!);
  }

  void _showOverlayAlert(BuildContext context, {required String msg, Function()? onAccept, Function()? onDecline, Color? iconColor, IconData? icon}) {
    overlayEntryConfirm = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Padding(
          padding: const EdgeInsets.only(left: 380, right: 380, top: 40),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Material(
                  color: Colors.white,
                  elevation: 10,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    width: 340,
                    height: 250,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            mouseCursor: SystemMouseCursors.click,
                            child: const Icon(
                              Icons.close,
                              color: PackageColors.fiord,
                              size: 36,
                            ),
                            onTap: () {
                              _removeDialog(overlayEntryConfirm);
                            },
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              icon ?? Icons.cancel,
                              size: 48,
                              color: iconColor ?? PackageColors.red,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                msg,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: PackageColors.blueBayoux),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SuitabilityButton(
                                  label: 'RECUSAR',
                                  primaryColor: PackageColors.red,
                                  alternativeButton: true,
                                  onTap: () {
                                    _removeDialog(overlayEntryConfirm);

                                    onDecline?.call();
                                  },
                                  mini: true,
                                ),
                                const SizedBox(width: 15),
                                SuitabilityButton(
                                  label: 'ACEITAR',
                                  primaryColor: PackageColors.darkPastelGreen,
                                  alternativeButton: true,
                                  onTap: () {
                                    _removeDialog(overlayEntryConfirm);

                                    onAccept?.call();
                                  },
                                  mini: true,
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(overlayEntryConfirm!);
  }

  bool _checkerNewQuestionInputs(List<TextEditingController> textEditingControllers, List<Answers> types) {
    var completeInputs = false;

    for (var item in textEditingControllers) {
      if (item.text == '') {
        return false;
      }
      completeInputs = true;
    }

    for (var item in types) {
      if (item.selected == true && completeInputs) {
        return true;
      }
    }

    return false;
  }

  Widget _footer() {
    return Container(
      decoration: BoxDecoration(
        color: widget.primaryColor.withOpacity(0.25),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20), // Defina o raio para o canto superior esquerdo
          bottomRight: Radius.circular(20), // Defina o raio para o canto superior direito
        ),
      ),
      height: 105,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (pageSelected.value > 0) ...[
            SuitabilityButton(
              primaryColor: widget.primaryColor,
              label: 'VOLTAR',
              onTap: () async {
                pageSelected.value--;

                overlayEntry?.markNeedsBuild();
              },
            ),
          ],
          const SizedBox(width: 24),
          SuitabilityButton(
            primaryColor: widget.primaryColor,
            label: pageSelected.value != _localSuitabilityQuestions.length - 1 ? 'CONTINUAR' : 'SALVAR MODELO',
            onTap: () async {
              if (pageSelected.value != _localSuitabilityQuestions.length - 1 && pageSelected.value < _localSuitabilityQuestions.length - 1) {
                pageSelected.value++;

                overlayEntry?.markNeedsBuild();
              } else {
                if (_localSuitabilityQuestions.isNotEmpty) {
                  final map = <String, dynamic>{
                    'formData': <String, dynamic>{
                      'sections': _localSuitabilityQuestions.map((question) => question.toJson()).toList(),
                    }
                  };

                  try {
                    loading = true;
                    overlayEntry?.markNeedsBuild();

                    Future.delayed(const Duration(seconds: 5), () async {
                      await widget.apiCallFunction(map).then(
                        (value) {
                          loading = false;
                          overlayEntry?.markNeedsBuild();
                        },
                      );
                    });
                  } catch (error) {
                    debugPrint('error on call api in suitability modal => ${error.toString()}');
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _header() {
    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('DEFINIR PERFIL DE INVESTIDOR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.primaryColor)),
        InkWell(
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          mouseCursor: SystemMouseCursors.click,
          child: const Icon(
            Icons.close,
            color: PackageColors.fiord,
            size: 36,
          ),
          onTap: () {
            _removeDialog(overlayEntry);

            widget.onCloseFunction?.call();
          },
        )
      ]),
      const SizedBox(height: 50),
      const Text(
          '''Para fazer bons investimentos é fundamental saber qual é o seu perfil de investidor. Com base nessas informações, podemos te auxiliar na escolha dos produtos ideais para você. E para descobri-lá, vamos te fazer algumas perguntas.''',
          style: TextStyle(fontSize: 18, color: PackageColors.brightGrey)),
      const SizedBox(height: 50),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: InkWell(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              mouseCursor: SystemMouseCursors.click,
              child: InputSuitability(
                controller: _sectionNameController,
                section: _localSuitabilityQuestions[pageSelected.value],
                overlay: overlayEntry,
                requestFocus: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Criar nova seção',
            child: InkWell(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                _showOverlayAlert(
                  context,
                  icon: Icons.my_library_add,
                  iconColor: PackageColors.brightGrey,
                  msg: 'Tem certeza que deseja criar uma nova seção?',
                  onAccept: () {
                    _localSuitabilityQuestions.add(Sections(
                      name: 'Nova Seção ${_localSuitabilityQuestions.length + 1}',
                      questions: [
                        Question(
                          name: 'Exemplo Pergunta 1',
                          answers: [
                            Answers(name: 'Exemplo resposta 1', selected: false),
                            Answers(name: 'Exemplo resposta 2', selected: false),
                            Answers(name: 'Exemplo resposta 3', selected: false),
                            Answers(name: 'Exemplo resposta 4', selected: false)
                          ],
                          layoutDesign: LayoutDesign.multipleChoice,
                        )
                      ],
                    ));

                    pageSelected.value++;

                    overlayEntry?.markNeedsBuild();
                  },
                );
              },
              child: const Icon(
                Icons.my_library_add,
                color: PackageColors.brightGrey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Tooltip(
            message: 'Deletar seção',
            child: InkWell(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                _showOverlayAlert(
                  context,
                  msg: 'Tem certeza que deseja apagar a seção?',
                  onAccept: () {
                    if (_localSuitabilityQuestions.length > 1) {
                      _localSuitabilityQuestions.removeAt(pageSelected.value);

                      if (pageSelected.value != 0) {
                        pageSelected.value--;
                      } else {
                        sectionSelected = _localSuitabilityQuestions[pageSelected.value];
                        _sectionNameController = TextEditingController(text: _localSuitabilityQuestions[pageSelected.value].name);
                      }

                      overlayEntry?.markNeedsBuild();
                    }
                  },
                );
              },
              child: const Icon(
                Icons.delete,
                color: PackageColors.brightGrey,
              ),
            ),
          ),
          const Spacer(flex: 4),
          bars(pageSelected: pageSelected.value),
        ],
      ),
      const SizedBox(height: 32)
    ];
  }

  List<Widget> questionsBuilder() {
    final res = <Widget>[];
    final pageQuestions = sectionSelected.questions;

    for (var i = 0; i < pageQuestions.length; i++) {
      res.add(
        questionWidgetBuild(
          index: i,
          question: pageQuestions[i].name,
          answer: pageQuestions[i].answers,
          questionLayout: pageQuestions[i].layoutDesign,
          isLast: true,
        ),
      );

      if (i == pageQuestions.length - 1) {
        res.addAll([
          const SizedBox(height: 32),
          InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              _showOverlayNewQuestion(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: PackageColors.fiord)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text('Adicionar nova pergunta', style: const TextStyle(color: PackageColors.fiord, fontSize: 16)),
                      SizedBox(height: 8),
                      Icon(
                        Icons.add,
                        size: 44,
                        color: PackageColors.fiord,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]);
      }
    }

    return res;
  }

  Widget questionWidgetBuild({required LayoutDesign questionLayout, required int index, required String question, required List<Answers> answer, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: PackageColors.fiord)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pergunta ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: PackageColors.brightGrey, fontSize: 14),
                ),
                Spacer(),
                Tooltip(
                  message: 'Editar pergunta',
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      _showOverlayNewQuestion(
                        context,
                        question: _localSuitabilityQuestions[pageSelected.value].questions[index],
                        index: index,
                      );
                    },
                    child: const Icon(
                      Icons.edit,
                      color: PackageColors.brightGrey,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Tooltip(
                  message: 'Deletar pergunta',
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      if (_localSuitabilityQuestions[pageSelected.value].questions.length > 1) {
                        _localSuitabilityQuestions[pageSelected.value].questions.removeAt(index);

                        overlayEntry?.markNeedsBuild();
                      }
                    },
                    child: Icon(
                      Icons.delete,
                      color: PackageColors.brightGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(child: Text(question, style: const TextStyle(color: PackageColors.brightGrey, fontSize: 16))),
            if (questionLayout == LayoutDesign.slider) ...[
              const SizedBox(height: 36),
              CustomSlider(
                primaryColor: widget.primaryColor,
                value: 25,
                divisions: 4, // Número de divisões do Slider
                labels: answer.map((item) => item.name).toList(), // Labels para os separadores
                onChanged: (double value) async {},
                disabled: true,
              )
            ] else ...[
              Column(
                children: [
                  const SizedBox(height: 16),
                  CustomRadioButton(
                    answers: answer,
                    primaryColor: widget.primaryColor,
                    onTap: () {
                      overlayEntry?.markNeedsBuild();
                    },
                    disabled: true,
                  )
                ],
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget bars({required int pageSelected}) {
    final maxPages = _localSuitabilityQuestions.length;

    if (maxPages > 2) {
      final percentPage = 3 / maxPages;

      final percent = percentPage * (pageSelected + 1);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _bar(pageSelected == 0
              ? 0.15
              : percent > 1
                  ? 1
                  : percent),
          const SizedBox(width: 10),
          _bar(percent > 1 && percent <= 2
              ? percent - 1 == 1
                  ? 0.85
                  : percent - 1
              : percent <= 1
                  ? 0
                  : 1),
          const SizedBox(width: 10),
          _bar(percent > 2
              ? percent - 2 == 1
                  ? 0.75
                  : percent - 2
              : 0)
        ],
      );
    }
    if (maxPages == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _bar(1),
          const SizedBox(width: 10),
          _bar(pageSelected == 0 ? 0.5 : 1),
          const SizedBox(width: 10),
          _bar(pageSelected == 0 ? 0 : 1),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _bar(1),
          const SizedBox(width: 10),
          _bar(1),
          const SizedBox(width: 10),
          _bar(1),
        ],
      );
    }
  }

  SizedBox _bar(double percent) {
    return SizedBox(
      width: 108,
      child: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5), // Ajuste o raio conforme necessário
          child: LinearProgressIndicator(
            color: widget.primaryColor,
            backgroundColor: PackageColors.gainsboro,
            value: percent,
          ),
        ),
      ),
    );
  }

  void _removeDialog(OverlayEntry? overlayEntry) {
    overlayEntry?.remove();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

///
///
///

class InputSuitability extends StatefulWidget {
  const InputSuitability({
    required this.controller,
    this.section,
    this.hintText,
    this.requestFocus = false,
    this.overlay,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final String? hintText;
  final OverlayEntry? overlay;
  final bool requestFocus;
  final Sections? section;

  @override
  State<InputSuitability> createState() => _InputSuitabilityState();
}

class _InputSuitabilityState extends State<InputSuitability> {
  late FocusNode _focus;
  late FocusNode _focusText;
  late Color _activeColor;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focusText = FocusNode();
    _activeColor = PackageColors.whiteSmoke25;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.addListener(() {
        if (_focus.hasFocus) {
          _activeColor = PackageColors.blueBayoux;
        } else {
          _activeColor = PackageColors.whiteSmoke25;
        }
        widget.overlay?.markNeedsBuild();
      });

      if (widget.requestFocus) {
        _focusText.requestFocus();
        widget.overlay?.markNeedsBuild();
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _focusText.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (DismissIntent intent) {
            _focusText.unfocus();
          },
        ),
      },
      child: Container(
        padding: widget.hintText != null ? null : const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(border: Border.all(color: _activeColor), borderRadius: BorderRadius.circular(10)),
        child: RawKeyboardListener(
          autofocus: true,
          focusNode: _focus,
          onKey: (event) {
            if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
              _focus.unfocus();
            } else if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
              _focus.nextFocus();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 3, left: 20, bottom: 5),
                child: TextFormField(
                  focusNode: _focusText,
                  style: const TextStyle(fontSize: 16, color: PackageColors.blueBayoux, fontWeight: FontWeight.w400),
                  controller: widget.controller,
                  cursorColor: PackageColors.blueBayoux,
                  onChanged: (value) {
                    widget.section?.name = widget.controller.text;
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    labelText: widget.hintText,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      color: PackageColors.darkGrey,
                      fontWeight: FontWeight.w300,
                    ),
                    floatingLabelStyle: const TextStyle(
                      fontSize: 18,
                      color: PackageColors.blueBayoux,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
///

class ShareButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String path;
  final Color primaryColor;
  final Function()? onTap;

  const ShareButton({
    required this.icon,
    required this.label,
    required this.path,
    required this.primaryColor,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _colorAnimation = ColorTween(begin: widget.primaryColor, end: widget.primaryColor.withOpacity(0.3)).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _updateColor(true),
      onExit: (event) => _updateColor(false),
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          widget.onTap?.call();
        },
        child: AnimatedDefaultTextStyle(
          style: TextStyle(color: _colorAnimation.value ?? widget.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
          duration: const Duration(milliseconds: 100),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: SvgPicture.network(
                  widget.path,
                  height: 24,
                  color: _colorAnimation.value ?? widget.primaryColor,
                  placeholderBuilder: (context) => AnimatedBuilder(
                    animation: _colorAnimation,
                    builder: (context, child) {
                      return Icon(
                        widget.icon,
                        color: _colorAnimation.value,
                        size: 24,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(widget.label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  void _updateColor(bool isHover) {
    if (isHover) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}

///

class ProductsWidget extends StatelessWidget {
  const ProductsWidget({
    Key? key,
    required this.primaryColor,
    required this.updateGoToNextPage,
    required this.goToNextPage,
  }) : super(key: key);

  final Color primaryColor;
  final ValueNotifier<bool> updateGoToNextPage;
  final bool goToNextPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PackageColors.linkWater),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(17.0), // Raio da borda superior esquerda
                topRight: Radius.circular(17.0), // Raio da borda inferior direita
              ),
              color: primaryColor.withOpacity(0.15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: const [
                SizedBox(height: 24),
                Text(
                  'Fundos',
                  style: TextStyle(
                    color: PackageColors.blueBayoux,
                    fontSize: 18,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'imobiliários',
                  style: TextStyle(
                    color: PackageColors.blueBayoux,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SuitabilityButton(
            primaryColor: primaryColor,
            label: 'CONSULTAR',
            mini: true,
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

///

class LoadingImageWidget extends StatefulWidget {
  final String? pathImageConfig;
  final Color primaryColor;

  const LoadingImageWidget({
    Key? key,
    this.pathImageConfig,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<LoadingImageWidget> createState() => _LoadingImageWidgetState();
}

class _LoadingImageWidgetState extends State<LoadingImageWidget> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller!);

    _controller!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation!,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.pathImageConfig != null) ...[
            widget.pathImageConfig!.endsWith('.svg')
                ? SvgPicture.network(
                    widget.pathImageConfig!,
                    height: 150,
                    placeholderBuilder: (context) => _defaultLoading(),
                  )
                : Image.network(
                    widget.pathImageConfig!,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) => _defaultLoading(),
                  ),
          ] else ...[
            _defaultLoading()
          ],
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              'Identificando o seu perfil para investir...',
              style: TextStyle(color: widget.primaryColor, fontSize: 20),
            ),
          )
        ],
      ),
    );
  }

  SizedBox _defaultLoading() {
    return SizedBox(
      height: 80,
      width: 80,
      child: CircularProgressIndicator(
        strokeWidth: 6,
        color: widget.primaryColor,
      ),
    );
  }
}

///
///
///

class SuitabilityButton extends StatefulWidget {
  final bool alternativeButton;
  final bool mini;
  final String label;
  final Color primaryColor;
  final Function() onTap;

  const SuitabilityButton({
    Key? key,
    required this.primaryColor,
    required this.label,
    required this.onTap,
    this.alternativeButton = false,
    this.mini = false,
  }) : super(key: key);

  @override
  State<SuitabilityButton> createState() => _SuitabilityButtonState();
}

class _SuitabilityButtonState extends State<SuitabilityButton> {
  late Color buttonColor;
  late FocusNode _focusNode;

  @override
  void initState() {
    buttonColor = widget.primaryColor;
    _focusNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => _updateColor(widget.primaryColor.withOpacity(0.3)),
      onExit: (event) => _updateColor(widget.primaryColor),
      child: InkWell(
        focusNode: _focusNode,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300), // Duração da animação
          padding: EdgeInsets.symmetric(horizontal: widget.mini ? 20 : 72, vertical: widget.mini ? 8 : 12),
          decoration: BoxDecoration(
              color: widget.alternativeButton ? widget.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(90),
              border: Border.all(
                width: 2,
                color: widget.alternativeButton
                    ? buttonColor == widget.primaryColor
                        ? widget.primaryColor
                        : lightenColor(lightenColor(widget.primaryColor))
                    : buttonColor,
              )),
          child: AnimatedDefaultTextStyle(
            style: TextStyle(
                color: widget.alternativeButton
                    ? buttonColor == widget.primaryColor
                        ? Colors.white
                        : lightenColor(lightenColor(widget.primaryColor))
                    : buttonColor,
                fontWeight: FontWeight.bold,
                fontSize: widget.mini ? 12 : 16),
            duration: const Duration(milliseconds: 300),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }

  void _updateColor(Color color) {
    setState(() {
      buttonColor = color;
    });
  }

  Color lightenColor(Color color, [double amount = .05]) {
    const max = 255;
    double r = color.red + max * amount;
    double g = color.green + max * amount;
    double b = color.blue + max * amount;
    return Color.fromARGB(
      color.alpha,
      r > max ? max : r.toInt(),
      g > max ? max : g.toInt(),
      b > max ? max : b.toInt(),
    );
  }
}

///
///
///

class CustomRadioButton extends StatefulWidget {
  final bool disabled;
  final bool alternative;
  final Color primaryColor;
  final List<Answers> answers;
  final Function() onTap;

  const CustomRadioButton({
    Key? key,
    required this.answers,
    required this.primaryColor,
    required this.onTap,
    this.alternative = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  @override
  Widget build(BuildContext context) {
    return widget.alternative
        ? Row(
            children: _buildQuestions(),
          )
        : Column(
            children: _buildQuestions(),
          );
  }

  List<Widget> _buildQuestions() {
    final res = <Widget>[];

    for (var answer in widget.answers) {
      res.add(
        Padding(
          padding: EdgeInsets.only(left: widget.alternative ? 0 : 40, bottom: 8),
          child: InkWell(
            mouseCursor: widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: widget.disabled
                ? null
                : () {
                    for (var item in widget.answers) {
                      item.selected = false;
                    }

                    answer.selected = true;

                    widget.onTap();
                  },
            child: Row(
              children: [
                Container(
                  height: widget.alternative ? 20 : 12,
                  width: widget.alternative ? 20 : 12,
                  decoration: BoxDecoration(
                    color: answer.selected ? widget.primaryColor : Colors.transparent, // Cor de fundo verde
                    shape: BoxShape.circle, // Forma circular
                    border: Border.all(
                      color: answer.selected ? widget.primaryColor : PackageColors.linkWater, // Cor da borda
                      width: 1, // Espessura da borda
                    ),
                  ),
                  child: Center(
                    child: Container(
                      height: widget.alternative ? 18 : 10, // Altura do círculo interno
                      width: widget.alternative ? 18 : 10, // Largura do círculo interno
                      decoration: BoxDecoration(
                        color: answer.selected ? widget.primaryColor : Colors.transparent, // Cor de fundo verde
                        shape: BoxShape.circle, // Forma circular
                        border: Border.all(
                          color: answer.selected ? Colors.white : Colors.transparent, // Cor da borda
                          width: 1.5, // Espessura da borda
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: widget.alternative ? 16 : 10),
                if (widget.alternative) ...[
                  Text(
                    answer.name,
                    style: const TextStyle(color: PackageColors.blueBayoux, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 40),
                ] else ...[
                  Expanded(
                    child: Text(
                      answer.name,
                      style: const TextStyle(color: PackageColors.brightGrey, fontSize: 14),
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      );
    }

    return res;
  }
}

///

class CustomSlider extends StatelessWidget {
  final int divisions;
  final int selectedLabel;
  final double value;
  final double sliderWidth;
  final bool disabled;
  final Color primaryColor;
  final List<String> labels;
  final ValueChanged<double>? onChanged;

  const CustomSlider({
    Key? key,
    required this.value,
    required this.labels,
    required this.divisions,
    required this.onChanged,
    required this.primaryColor,
    this.sliderWidth = 500,
    this.selectedLabel = 20,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              overlayColor: Colors.transparent,
              thumbColor: Colors.white,
              activeTickMarkColor: primaryColor,
              inactiveTrackColor: PackageColors.whiteSmoke50,
              activeTrackColor: primaryColor,
              tickMarkShape: CircleTickMarkShape(primaryColor: primaryColor, tickMarkRadius: 7, sliderValue: value),
              thumbShape: CircleSliderThumb(thumbRadius: 10.0, primaryColor: primaryColor),
            ),
            child: Slider(
              mouseCursor: disabled ? SystemMouseCursors.basic : null,
              value: value,
              max: 100,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ..._buildTextValues(
                  labels,
                  value,
                  selectedLabel,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildTextValues(List<String> labels, double value, int selectedValue) {
    final res = <Widget>[];

    for (var i = 0; i < labels.length; i++) {
      res.add(
        Expanded(
          child: Text(
            labels[i],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selectedValue > value ? FontWeight.normal : FontWeight.bold,
              color: selectedValue > value ? PackageColors.brightGrey : primaryColor,
            ),
          ),
        ),
      );

      selectedValue += 20;
    }

    return res;
  }
}

class CircleSliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final Color primaryColor;

  const CircleSliderThumb({required this.thumbRadius, required this.primaryColor});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter, // Incluído, mas não usado
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value, // Incluído, mas não usado
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    double outerCircleRadius = thumbRadius;
    double innerCircleRadius = thumbRadius * 0.45;

    final outerCircleColor = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, outerCircleRadius, outerCircleColor);

    final innerCircleColor = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerCircleRadius, innerCircleColor);
  }
}

class CircleTickMarkShape extends SliderTickMarkShape {
  final double tickMarkRadius;
  final double sliderValue; // Valor atual do Slider
  final double minValue; // Valor mínimo do Slider
  final Color primaryColor;

  CircleTickMarkShape({
    this.tickMarkRadius = 10.0,
    required this.sliderValue,
    required this.primaryColor,
    this.minValue = 0.0, // Defina o valor mínimo aqui, se for diferente de 0, ajuste
  });

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
  }) {
    return Size.fromRadius(tickMarkRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    bool isEnabled = false,
    TextDirection? textDirection,
  }) {
    final Canvas canvas = context.canvas;

    // Adicionado: Evita desenhar o primeiro tick comparando a posição do tick com um valor de deslocamento mínimo
    if (center.dx < 100.0) return; // Você pode ajustar o valor '10.0' conforme necessário

    // Resto do código permanece o mesmo...
    Color color = center.dx < thumbCenter.dx ? primaryColor : PackageColors.whiteSmoke50;

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, tickMarkRadius, paint);
  }
}

///
///
///

class PackageColors {
  static const Color brightGrey = Color(0xFF58585A);
  static const Color blueBayoux = Color(0xFF576872);
  static const Color darkGrey = Color(0xFFAAAAAA);
  static const Color darkPastelGreen = Color(0xFF00C550);
  static const Color fiord = Color(0xFF4F5D63);
  static const Color gainsboro = Color(0xFFD9D9D9);
  static const Color linkWater = Color(0xFFCCD4D9);
  static const Color red = Color(0xFFEC0505);
  static const Color whiteSmoke = Color(0xFFF9F9F9);
  static const Color whiteSmoke25 = Color(0xFFECECEC);
  static const Color whiteSmoke50 = Color(0xFFEDEDED);
  static const Color whiteSmoke75 = Color(0xFFEAEAEA);
}

class Sections {
  String name;
  List<Question> questions;

  Sections({
    required this.name,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  Sections.deepCopy(Sections source)
      : name = source.name,
        questions = source.questions.map((question) => question.deepCopy()).toList();

  Sections deepCopy() {
    return Sections.deepCopy(this);
  }
}

class Question {
  String name;
  List<Answers> answers;
  LayoutDesign layoutDesign;

  Question({
    required this.name,
    required this.answers,
    required this.layoutDesign,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'layoutDesign': layoutDesign == LayoutDesign.multipleChoice ? 'multipleChoice' : 'slider',
    };
  }

  Question.deepCopy(Question source)
      : name = source.name,
        layoutDesign = source.layoutDesign,
        answers = source.answers.map((answer) => answer.deepCopy()).toList();

  Question deepCopy() {
    return Question.deepCopy(this);
  }
}

class Answers {
  String name;
  bool selected;

  Answers({
    required this.name,
    this.selected = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'selected': selected,
    };
  }

  Answers.deepCopy(Answers source)
      : name = source.name,
        selected = source.selected;

  Answers deepCopy() {
    return Answers.deepCopy(this);
  }
}

class ShareIcons {
  final String whatsappSvgIconPath;
  final String mailSvgIconPath;
  final String downloadSvgIconPath;
  final List<bool> enable;
  final List<Function()?> functions;

  List<String> get getPaths => [whatsappSvgIconPath, mailSvgIconPath, downloadSvgIconPath];
  List<IconData> get getIcons => [Icons.phone, Icons.mail, Icons.download_for_offline];
  List<String> get getLabels => ['Whatsapp', 'E-mail', 'Baixar PDF'];
  List<bool> get enabled => enable;

  const ShareIcons({
    this.whatsappSvgIconPath = '.svg',
    this.mailSvgIconPath = '.svg',
    this.downloadSvgIconPath = '.svg',
    this.enable = const [true, true, true],
    this.functions = const [null, null, null],
  });
}

enum LayoutDesign { multipleChoice, slider }
