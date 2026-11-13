# 🤖 Além dos Cliques: Do Que o Robot Framework é Capaz em 2026?
### *Como construí uma Arquitetura de QA Ops Full-Stack com Playwright, Contratos OpenAPI 3.0.3, Mobile Nativo (Android e iOS XCUITest), Telemetria de Performance SLA e Inteligência Artificial*

> **Autor:** Galileo Guilherme — QA Engineer & Especialista em Automação de Testes de Software  
> **Repositório do Projeto:** [github.com/GalileoGuilherme/robot-qa-lab](https://github.com/GalileoGuilherme/robot-qa-lab)  
> **Aplicação sob Teste:** [portfolio-omega-six-18.vercel.app](https://portfolio-omega-six-18.vercel.app/)

---

## 💡 O Mito: "Robot Framework é apenas um wrapper legado de Selenium?"

Se você atua na área de Engenharia de Qualidade de Software (SDET / QA Ops), certamente já ouviu afirmações como:
- *"Robot Framework é lento e só serve para testes legados com Selenium."*
- *"Robot é engessado e não serve para arquiteturas corporativas modernas."*
- *"Frameworks modernos de JavaScript/TypeScript são os únicos capazes de fazer testes de ponta."*

Essas afirmações não apenas estão desatualizadas, como ignoram a maior força do Robot Framework: **ele não é apenas uma ferramenta de UI, mas sim um ecossistema agnóstico e extensível de automação alimentado por Python.**

Para colocar essa premissa à prova e explorar a fronteira do que a automação moderna exige, desenvolvi o **[Robot QA Lab](https://github.com/GalileoGuilherme/robot-qa-lab)**. Um projeto corporativo completo que cobre **44 cenários automatizados** em uma arquitetura **Full-Stack 5D**:

1. **Web E2E de Alta Velocidade** com Playwright nativo.
2. **Backend REST API** com validação estrita de contratos OpenAPI 3.0.3.
3. **Mobile Multiplataforma Nativo** para Android (`UiAutomator2`) e iOS (`XCUITest`).
4. **Telemetria de Performance Leve** com cálculo de latência percentílica (**P95**) e **W3C Navigation Timing**.
5. **Observabilidade Autônoma com IA** (Google Gemini 2.5 Flash + contingência local de SDET) e **disparo automático de e-mail executivo escuro via SMTP**.

Abaixo, detalho como essa engenharia foi estruturada e como você pode extrair o máximo do Robot Framework em projetos reais.

---

## 🏗️ 1. A Nova Era da Web: Robot Framework + Playwright Engine

Durante anos, o calcanhar de Aquiles do Robot foi a dependência do Selenium clássico, famoso por sincronizações manuais frágeis (`Sleep`, esperas implícitas) e lentidão.

No **Robot QA Lab**, eliminamos o Selenium para a camada web e adotamos a **Browser Library oficial impulsionada pelo motor Playwright**:

- **Isolamento Total por Contextos:** Cada teste roda em um contexto independente e descartável, eliminando efeitos colaterais de cookies e cache em milissegundos.
- **Auto-Waiting Nativo:** O framework aguarda automaticamente que os nós do DOM estejam anexados, estáveis, visíveis e receptivos antes de qualquer interação.
- **Strict-Mode Heuristics:** O Playwright bloqueia execuções ambíguas caso um seletor retorne mais de um nó, forçando a construção de seletores semânticos e estáveis.
- **Testes Reais de E-commerce:** Cobrimos busca com debounce em tempo real, filtros de categorias, manipulação de múltiplos itens no carrinho, validação de regras de cupom de desconto e checkout completo com emissão de identificador de pedido (`QA-XXXXXX`).

```robotframework
*** Test Cases ***
Scenario: Complete Full Checkout Flow With Order Confirmation
    [Documentation]    Adiciona produto, preenche dados, aceita termos e valida confirmação.
    [Tags]    checkout    critical    e2e
    Login To Automation Store
    Add Product To Cart            fone-bluetooth
    Fill Delivery Address          Rua dos Testes Automatizados, 100 - Recife, PE
    Accept Terms And Conditions
    Submit Checkout Order
    ${order_id}=                   Verify Order Confirmation Displayed
    Log    Pedido criado com sucesso: ${order_id}    console=True
```

---

## 🔌 2. Backend REST API com Validação Estrita de Contrato OpenAPI 3.0.3

Testar API via interface é lento e oneroso. No **Robot QA Lab**, o backend em produção ([/api](https://portfolio-omega-six-18.vercel.app/api)) é exercitado diretamente na camada de rede com a `RequestsLibrary`.

O grande diferencial de engenharia foi o desenvolvimento de uma **biblioteca customizada em Python (`libraries/JsonSchemaValidator.py`)** encapsulando o validador `Draft7Validator`:

- **Blindagem de Contrato:** Toda resposta de endpoint (`/api/health`, `/api/products`, `/api/orders`, `/api/auth/login`, `/api/coupons/validate`, `/api/shipping/calculate`) tem seus tipos de dados, campos obrigatórios, padrões regex e formatos ISO validados contra esquemas JSON derivados da especificação oficial do Swagger OpenAPI.
- **Segurança e Idempotência:** Testes de sanitização de formulários contra XSS, rejeição de payloads com itens vazios (HTTP 400) e geração de tokens JWT seguros.

```robotframework
Scenario: Create Valid Order And Validate OpenAPI Contract
    [Documentation]    Valida geração de pedido (HTTP 201), formato ORD-XXXX e schema.
    [Tags]    contract    smoke    critical
    ${item}=        Create Sample Order Item
    ${items_list}=  Create List    ${item}
    ${payload}=     Create Dictionary
    ...    customerName=Galileo Guilherme SDET
    ...    customerEmail=galileo.qa@example.com
    ...    address=Rua dos Testes, 42 - Recife, PE
    ...    items=${items_list}
    ${response}=    Post Order    ${payload}
    Assert Order Successful       ${response}
    Validate Order Contract       ${response}
```

---

## 📱 3. Mobile Multiplataforma Nativo: Android e iOS XCUITest

A automação móvel costuma ser tratada como um silo isolado. No Robot Framework, unificamos as plataformas sob o padrão **Screen Object Model**:

- **Android Nativo (`UiAutomator2`):** Execução contra o aplicativo SwagLabs (`com.swaglabsmobileapp`), com automação de formulários, alertas de erro de login e navegação de catálogo.
- **iOS Nativo (`XCUITest`):** Automação no **iPhone 15 Pro (iOS 17.2)** utilizando os seletores mais performáticos do ecossistema Apple: **iOS Predicate Strings** (`predicate=name == "test-Username"`) e **iOS Class Chains** (`class_chain=**/XCUIElementTypeStaticText`), garantindo estabilidade máxima.
- **Emulação Touch & Auditoria WCAG 2.2:** Além dos apps nativos, a suíte audita o comportamento responsivo mobile no navegador emulando toques reais e inspecionando o *bounding box* dos elementos para assegurar que inputs e botões cumpram o padrão mínimo de acessibilidade ergonômica (**>= 44x44px**).
- **Resiliência de Infraestrutura (Graceful Skip):** Em máquinas de desenvolvedores onde o nó do Appium não estiver ativo na porta 4723, a suíte detecta a ausência e marca o teste como `SKIP` explicativo, mantendo o pipeline verde e sem falhas acidentais.

---

## ⚡ 4. Telemetria de Performance Leve & Orçamentos de SLA

Quem disse que testes funcionais não podem auditar performance?

Criamos a biblioteca `libraries/PerformanceTelemetry.py`, que transforma o Robot Framework em uma ferramenta contínua de observabilidade de performance sem precisar de infraestruturas pesadas de teste de carga:

1. **Benchmarking com Cálculo de Percentil 95 (P95):**
   - Executa baterias controladas de requisições utilizando timers de alta resolução (`time.perf_counter()`).
   - Calcula a distribuição estatística: Mínimo, Médio, Mediana (P50), P90 e **P95**.
   - **Falha automática por SLA:** Se o P95 de um endpoint ultrapassar 900ms, o teste é reprovado.
   - Audita o jitter de rede e orçamentos de tamanho de payload (`< 100 KB`).

2. **Auditoria W3C Navigation Timing API no Navegador:**
   - Injeta JavaScript para coletar métricas reais de carregamento percebidas pelo usuário:
     - `TTFB (Time to First Byte):` tempo de resposta inicial do servidor.
     - `DOM Interactive:` momento em que o DOM fica navegável.
     - `Load Event Time:` conclusão de scripts e folhas de estilo.

```
⚡ API SLA BENCHMARK SUMMARY: GET /api/health
Iterations: 8 | Min: 191ms | Average: 229ms | P95: 327ms | Max: 329ms
Target SLA P95: 900 ms -> PASSED ✅
```

---

## 🧠 5. Observabilidade Autônoma com IA & E-mail Executivo via SMTP

A cereja do bolo deste projeto foi conectar a esteira a um **Observador de Qualidade Inteligente** ([scripts/ai_qa_observer.py](file:///c:/Users/galil/OneDrive/Documentos/GitHub/robot-qa-lab/scripts/ai_qa_observer.py)):

- **Operação em Modo Duplo:**
  - **Com Google Gemini 2.5 Flash:** O observador analisa o `output.xml`, as taxas de êxito e a saúde em tempo real do backend, gerando um parecer de liderança técnica em três dimensões: integridade funcional, telemetria de performance e acessibilidade móvel.
  - **Contingência Silenciosa (Silent Fallback):** Caso não haja chave ou a API esteja offline, o **Motor Analítico Local de SDET** assume instantaneamente, garantindo entrega do relatório limpo sem vazar erros técnicos.
- **Relatório Executivo em HTML Escuro:** Compilação de um template no padrão `⚡ QA OPS INTELLIGENCE`, com cartões de KPIs (Total, Aprovados, Ignorados, Taxa de Êxito), tabela de suítes e botões de ação com 1 clique (1-Click Re-run).
- **Disparo Automático via SMTP:** O relatório é disparado automaticamente via SMTP para o e-mail do stakeholder (`galileoguilhermeqa@gmail.com`), permitindo que a liderança técnica visualize a saúde da esteira diretamente no smartphone.

---

## 📈 Conclusão & Próximos Passos

O **Robot Framework QA Lab** prova que o Robot Framework não é uma ferramenta do passado, mas sim uma das plataformas de orquestração de testes mais elegantes, extensíveis e poderosas da atualidade quando combinada com as tecnologias certas:

✅ **Playwright** para velocidade e estabilidade web.  
✅ **OpenAPI & JSON Schema** para integridade de microsserviços.  
✅ **Appium 2.x & XCUITest** para excelência mobile multiplataforma.  
✅ **Telemetria de SLA** para garantir velocidade contínua da aplicação.  
✅ **Inteligência Artificial & SMTP** para transformar relatórios de teste em inteligência de negócio acionável.

---

### 🔗 Explore o Código e Execute Você Mesmo

Todo o código está documentado, versionado e disponível publicamente:

- 🐙 **Repositório GitHub:** [https://github.com/GalileoGuilherme/robot-qa-lab](https://github.com/GalileoGuilherme/robot-qa-lab)
- 🛒 **Laboratório E2E:** [https://portfolio-omega-six-18.vercel.app/automation](https://portfolio-omega-six-18.vercel.app/automation)
- 💼 **Conecte-se comigo no LinkedIn:** [linkedin.com/in/galileoguilherme](https://www.linkedin.com/in/galileoguilherme/)

*Se você gostou deste conteúdo ou quer trocar experiências sobre QA Ops, deixe seu comentário ou estrela no repositório!* 🚀
