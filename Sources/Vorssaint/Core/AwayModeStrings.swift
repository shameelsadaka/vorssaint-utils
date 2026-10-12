// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct AwayModeStrings {
    let title: String
    let description: String
    let start: String
    let unlockHint: String
    let showAgents: String
    let agentsHint: String
    let keepAwake: String
    let notice: String
    let authenticate: String
    let unavailable: String

    static func get(_ language: AppLanguage) -> AwayModeStrings {
        switch language {
        case .enUS:
            return AwayModeStrings(
                title: "Away Mode",
                description: "Guard input and cover every display while your apps keep working.",
                start: "Start Away Mode",
                unlockHint: "Press Escape 3 times to authenticate",
                showAgents: "Show AI-agent activity",
                agentsHint: "Uses the AI agents already enabled in Dynamic Island. Otherwise, a quiet orbit appears.",
                keepAwake: "Keep Mac and displays awake",
                notice: "An input guard, not the macOS security lock.",
                authenticate: "Authenticate to restore controls",
                unavailable: "Away Mode could not start. Check Accessibility and device-owner authentication, then try again.")
        case .ptBR:
            return AwayModeStrings(
                title: "Modo ausente",
                description: "Bloqueie a entrada e cubra todas as telas enquanto seus apps continuam trabalhando.",
                start: "Iniciar modo ausente",
                unlockHint: "Pressione Escape 3 vezes para autenticar",
                showAgents: "Mostrar atividade dos agentes de IA",
                agentsHint: "Usa os agentes de IA já ativados na Ilha Dinâmica. Caso contrário, mostra uma órbita discreta.",
                keepAwake: "Manter o Mac e as telas acordados",
                notice: "Proteção de entrada, não o bloqueio de segurança do macOS.",
                authenticate: "Autentique para restaurar os controles",
                unavailable: "Não foi possível iniciar. Verifique Acessibilidade e a autenticação do proprietário e tente novamente.")
        case .tr:
            return AwayModeStrings(
                title: "Uzakta Modu",
                description: "Uygulamalar çalışırken girişi engelleyin ve tüm ekranları kaplayın.",
                start: "Uzakta Modunu başlat",
                unlockHint: "Kimlik doğrulamak için Escape tuşuna 3 kez basın",
                showAgents: "Yapay zekâ ajanı etkinliğini göster",
                agentsHint: "Dinamik Ada’da etkinleştirilmiş ajanları kullanır. Aksi hâlde sakin bir yörünge gösterilir.",
                keepAwake: "Mac’i ve ekranları uyanık tut",
                notice: "Giriş korumasıdır; macOS güvenlik kilidi değildir.",
                authenticate: "Kontrolleri geri açmak için kimliğinizi doğrulayın",
                unavailable: "Başlatılamadı. Erişilebilirliği ve aygıt sahibi kimlik doğrulamasını kontrol edip tekrar deneyin.")
        case .ru:
            return AwayModeStrings(
                title: "Режим отсутствия",
                description: "Блокирует ввод и закрывает все экраны, пока приложения продолжают работать.",
                start: "Включить режим отсутствия",
                unlockHint: "Нажмите Escape 3 раза для аутентификации",
                showAgents: "Показывать активность ИИ-агентов",
                agentsHint: "Использует агентов, уже включённых в Dynamic Island. Иначе отображается спокойная орбита.",
                keepAwake: "Не давать Mac и экранам засыпать",
                notice: "Защита от ввода, а не системная блокировка macOS.",
                authenticate: "Подтвердите личность, чтобы вернуть управление",
                unavailable: "Не удалось запустить. Проверьте Универсальный доступ и аутентификацию владельца, затем повторите.")
        case .es:
            return AwayModeStrings(
                title: "Modo ausente",
                description: "Bloquea la entrada y cubre todas las pantallas mientras tus apps siguen trabajando.",
                start: "Iniciar modo ausente",
                unlockHint: "Pulsa Escape 3 veces para autenticarte",
                showAgents: "Mostrar actividad de agentes de IA",
                agentsHint: "Usa los agentes ya activados en Dynamic Island. En su ausencia, muestra una órbita discreta.",
                keepAwake: "Mantener el Mac y las pantallas activos",
                notice: "Protege la entrada; no sustituye al bloqueo de seguridad de macOS.",
                authenticate: "Autentícate para recuperar los controles",
                unavailable: "No se pudo iniciar. Comprueba Accesibilidad y la autenticación del propietario e inténtalo de nuevo.")
        case .sk:
            return AwayModeStrings(
                title: "Režim neprítomnosti",
                description: "Zablokuje vstup a zakryje všetky displeje, kým aplikácie ďalej pracujú.",
                start: "Spustiť režim neprítomnosti",
                unlockHint: "Na overenie stlačte Escape 3-krát",
                showAgents: "Zobraziť aktivitu AI agentov",
                agentsHint: "Používa agentov už zapnutých v Dynamic Island. Inak zobrazuje pokojnú obežnú dráhu.",
                keepAwake: "Udržiavať Mac a displeje bdelé",
                notice: "Ochrana vstupu, nie bezpečnostný zámok macOS.",
                authenticate: "Overte sa na obnovenie ovládania",
                unavailable: "Spustenie zlyhalo. Skontrolujte Prístupnosť a overenie vlastníka a skúste to znova.")
        case .de:
            return AwayModeStrings(
                title: "Abwesenheitsmodus",
                description: "Sperrt Eingaben und deckt alle Displays ab, während deine Apps weiterarbeiten.",
                start: "Abwesenheitsmodus starten",
                unlockHint: "Escape 3-mal drücken, um dich zu authentifizieren",
                showAgents: "KI-Agentenaktivität anzeigen",
                agentsHint: "Nutzt die bereits in Dynamic Island aktivierten Agenten. Sonst erscheint eine ruhige Umlaufbahn.",
                keepAwake: "Mac und Displays wach halten",
                notice: "Eine Eingabesperre, keine macOS-Sicherheitssperre.",
                authenticate: "Authentifiziere dich, um die Steuerung wiederherzustellen",
                unavailable: "Start fehlgeschlagen. Prüfe Bedienungshilfen und die Geräteauthentifizierung und versuche es erneut.")
        case .fr:
            return AwayModeStrings(
                title: "Mode absence",
                description: "Bloque les entrées et couvre tous les écrans pendant que les apps continuent de travailler.",
                start: "Activer le mode absence",
                unlockHint: "Appuyez 3 fois sur Échap pour vous authentifier",
                showAgents: "Afficher l’activité des agents IA",
                agentsHint: "Utilise les agents déjà activés dans Dynamic Island. Sinon, affiche une orbite discrète.",
                keepAwake: "Garder le Mac et les écrans éveillés",
                notice: "Une protection des entrées, pas le verrouillage de sécurité de macOS.",
                authenticate: "Authentifiez-vous pour rétablir les commandes",
                unavailable: "Démarrage impossible. Vérifiez Accessibilité et l’authentification du propriétaire, puis réessayez.")
        case .it:
            return AwayModeStrings(
                title: "Modalità assente",
                description: "Blocca gli input e copre tutti gli schermi mentre le app continuano a lavorare.",
                start: "Avvia modalità assente",
                unlockHint: "Premi Esc 3 volte per autenticarti",
                showAgents: "Mostra attività degli agenti IA",
                agentsHint: "Usa gli agenti già attivati in Dynamic Island. Altrimenti mostra un’orbita discreta.",
                keepAwake: "Mantieni attivi il Mac e gli schermi",
                notice: "Protegge gli input; non è il blocco di sicurezza di macOS.",
                authenticate: "Autenticati per ripristinare i controlli",
                unavailable: "Avvio non riuscito. Controlla Accessibilità e l’autenticazione del proprietario, poi riprova.")
        case .ja:
            return AwayModeStrings(
                title: "離席モード",
                description: "アプリの動作を続けながら、入力をブロックしてすべての画面を覆います。",
                start: "離席モードを開始",
                unlockHint: "認証するにはEscapeを3回押してください",
                showAgents: "AIエージェントの動作を表示",
                agentsHint: "Dynamic Islandで有効なエージェントを使用します。それ以外は静かな軌道を表示します。",
                keepAwake: "Macと画面をスリープさせない",
                notice: "入力保護であり、macOSのセキュリティロックではありません。",
                authenticate: "操作を再開するには認証してください",
                unavailable: "開始できませんでした。アクセシビリティとデバイス所有者認証を確認し、再試行してください。")
        case .ko:
            return AwayModeStrings(
                title: "자리 비움 모드",
                description: "앱이 계속 작업하는 동안 입력을 차단하고 모든 화면을 덮습니다.",
                start: "자리 비움 모드 시작",
                unlockHint: "인증하려면 Escape를 3번 누르세요",
                showAgents: "AI 에이전트 활동 표시",
                agentsHint: "Dynamic Island에서 이미 활성화된 에이전트를 사용합니다. 그렇지 않으면 잔잔한 궤도를 표시합니다.",
                keepAwake: "Mac과 화면을 깨어 있게 유지",
                notice: "입력 보호 기능이며 macOS 보안 잠금이 아닙니다.",
                authenticate: "제어를 복원하려면 인증하세요",
                unavailable: "시작할 수 없습니다. 손쉬운 사용 및 기기 소유자 인증을 확인한 후 다시 시도하세요.")
        case .uk:
            return AwayModeStrings(
                title: "Режим відсутності",
                description: "Блокує введення й закриває всі екрани, поки програми продовжують працювати.",
                start: "Увімкнути режим відсутності",
                unlockHint: "Натисніть Escape 3 рази для автентифікації",
                showAgents: "Показувати активність ШІ-агентів",
                agentsHint: "Використовує агентів, уже ввімкнених у Dynamic Island. Інакше показує спокійну орбіту.",
                keepAwake: "Не давати Mac і екранам засинати",
                notice: "Захист від введення, а не системне блокування macOS.",
                authenticate: "Підтвердьте особу, щоб відновити керування",
                unavailable: "Не вдалося запустити. Перевірте Доступність і автентифікацію власника, потім повторіть.")
        case .zhHans:
            return AwayModeStrings(
                title: "离开模式",
                description: "阻止输入并覆盖所有显示器，同时让应用继续工作。",
                start: "启动离开模式",
                unlockHint: "按 Escape 3 次以验证身份",
                showAgents: "显示 AI 智能体活动",
                agentsHint: "使用灵动岛中已启用的智能体，否则显示安静的轨道动画。",
                keepAwake: "保持 Mac 和显示器唤醒",
                notice: "这是输入保护，不是 macOS 安全锁屏。",
                authenticate: "验证身份以恢复控制",
                unavailable: "无法启动。请检查辅助功能权限和设备所有者身份验证，然后重试。")
        case .zhTW:
            return AwayModeStrings(
                title: "離開模式",
                description: "阻擋輸入並覆蓋所有顯示器，同時讓 App 繼續工作。",
                start: "啟動離開模式",
                unlockHint: "按 Escape 3 次以驗證身分",
                showAgents: "顯示 AI 代理程式活動",
                agentsHint: "使用動態島中已啟用的代理程式，否則顯示安靜的軌道動畫。",
                keepAwake: "保持 Mac 和顯示器喚醒",
                notice: "這是輸入保護，不是 macOS 安全鎖定。",
                authenticate: "驗證身分以恢復控制",
                unavailable: "無法啟動。請檢查輔助使用權限和裝置擁有者驗證，然後重試。")
        case .zhHK:
            return AwayModeStrings(
                title: "離開模式",
                description: "阻擋輸入並覆蓋所有顯示器，同時讓 App 繼續工作。",
                start: "啟動離開模式",
                unlockHint: "按 Escape 3 次以驗證身分",
                showAgents: "顯示 AI 代理程式活動",
                agentsHint: "使用動態島中已啟用的代理程式，否則顯示安靜的軌道動畫。",
                keepAwake: "保持 Mac 和顯示器喚醒",
                notice: "這是輸入保護，並非 macOS 安全鎖定。",
                authenticate: "驗證身分以恢復控制",
                unavailable: "無法啟動。請檢查輔助使用權限及裝置擁有者驗證，然後重試。")
        }
    }
}

// Labels shared by the feature page and the minimal activity cards.
extension AwayModeStrings {
    static func controls(_ language: AppLanguage) -> (menu: String, island: String, working: String) {
        switch language {
        case .enUS: return ("Show in menu bar", "Show in Dynamic Island", "Working")
        case .ptBR: return ("Mostrar na barra de menus", "Mostrar na Ilha Dinâmica", "Trabalhando")
        case .tr: return ("Menü çubuğunda göster", "Dinamik Ada’da göster", "Çalışıyor")
        case .ru: return ("Показывать в строке меню", "Показывать в Dynamic Island", "Работает")
        case .es: return ("Mostrar en la barra de menús", "Mostrar en Dynamic Island", "Trabajando")
        case .sk: return ("Zobraziť v lište menu", "Zobraziť v Dynamic Island", "Pracuje")
        case .de: return ("In der Menüleiste anzeigen", "In Dynamic Island anzeigen", "Arbeitet")
        case .fr: return ("Afficher dans la barre des menus", "Afficher dans Dynamic Island", "En cours")
        case .it: return ("Mostra nella barra dei menu", "Mostra in Dynamic Island", "In corso")
        case .ja: return ("メニューバーに表示", "Dynamic Islandに表示", "作業中")
        case .ko: return ("메뉴 막대에 표시", "Dynamic Island에 표시", "작업 중")
        case .uk: return ("Показувати в рядку меню", "Показувати в Dynamic Island", "Працює")
        case .zhHans: return ("在菜单栏中显示", "在灵动岛中显示", "工作中")
        case .zhTW: return ("在選單列中顯示", "在動態島中顯示", "工作中")
        case .zhHK: return ("在選單列顯示", "在動態島顯示", "工作中")
        }
    }
}
