import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../models/meme_signal.dart';
import '../services/meme_signal_service.dart';
import '../services/free_signal_generation_service.dart';
import '../theme.dart';
import 'signal_detail_screen.dart';
import '../widgets/app_page_header.dart';
import '../services/subscription_state.dart';
import 'subscription_screen.dart';
import '../services/signal_service.dart';

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  AvexaColors get colors => Theme.of(context).extension<AvexaColors>()!;

  String get _language =>
      AppLocalizations.of(context)?.localeName.split('_').first ?? 'en';

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'signals': 'Signals',
      'free': 'FREE',
      'freeLimit': 'Up to 3 signals / 24h',
      'pro': 'PRO',
      'unlimited': 'Unlimited AI signals',
      'disclaimer': 'Signals are AI-generated market analysis,\nnot financial advice.',
      'cooldownTitle': 'NEXT SIGNAL AVAILABLE IN',
      'cooldownDescription': 'Your next free scan will be available when the cooldown ends.',
      'ready': 'READY TO SCAN',
      'dailyLimit': 'DAILY LIMIT REACHED',
      'readyDescription': 'Let AI search for the next qualifying\nSolana memecoin setup.',
      'limitDescription': 'You have used all 3 free signals\navailable in the current 24h window.',
      'cooldownRemaining': 'COOLDOWN REMAINING',
      'signalsUsed': 'signals used',
      'generate': 'GENERATE FREE SIGNAL',
      'scanTime': 'AI scan can take up to 5 minutes.',
      'todayFree': "TODAY'S FREE SIGNAL",
      'oneFree': 'One free signal is available today.',
      'reveal': 'REVEAL SIGNAL',
      'noSignal': 'NO SIGNAL FOUND',
      'noSignalDescription': "The AI didn't find a qualifying setup this time.\nYour free signal has not been used.",
      'ok': 'OK',
      'generationError': 'Unable to generate a signal. Please try again.',
      'cooldownMessage': 'Your previous free signal is still in cooldown.',
      'scanning': 'SCANNING MARKET...',
      'scanningDescription': 'AI is looking for a qualifying\nSolana memecoin setup.',
      'leaveOpen': 'You can leave this screen open while AI scans.',
      'active': 'SIGNAL ACTIVE',
      'expired': 'SIGNAL EXPIRED',
      'entry': 'ENTRY',
      'stopLoss': 'STOP LOSS',
      'takeProfit': 'TAKE PROFIT 1',
      'confidence': 'AI CONFIDENCE',
      'viewSignal': 'VIEW SIGNAL',
      'risk': 'RISK',
      'token': 'TOKEN',
      'market': 'MARKET',
      'solanaMeme': 'SOLANA MEME',
      'dex': 'VIEW ON DEXSCREENER',
      'proAccess': 'PRO ACCESS ACTIVE',
      'proSignal': 'PRO SIGNAL',
      'generating': 'Signal is generating',
      'unlockEngine': 'Unlock the full signal engine',
      'proDescription': 'Unlimited signals, full analysis\nand advanced market data.',
      'unlockPro': 'UNLOCK AVEXA PRO',
      'fullAnalysis': 'Full signal analysis',
      'alerts': 'Real-time alerts',
      'unlimitedSignals': 'Unlimited AI signals',
      'paywallDescription': 'Get unlimited AI trading signals, full signal analysis and advanced market data.',
      'solanaMemePro': 'SOLANA MEME',
      'proAiSignal': 'PRO  •  AI SIGNAL',
      'viewDetails': 'VIEW SIGNAL',
    },
    'pl': {
      'signals': 'Sygnały',
      'free': 'DARMOWE',
      'freeLimit': 'Do 3 sygnałów / 24 godz.',
      'pro': 'PRO',
      'unlimited': 'Nielimitowane sygnały AI',
      'disclaimer': 'Sygnały to analiza rynku generowana przez AI,\na nie porada finansowa.',
      'cooldownTitle': 'NASTĘPNY SYGNAŁ ZA',
      'cooldownDescription': 'Kolejny darmowy skan będzie dostępny po zakończeniu przerwy.',
      'ready': 'GOTOWY DO SKANOWANIA',
      'dailyLimit': 'OSIĄGNIĘTO LIMIT DZIENNY',
      'readyDescription': 'Pozwól AI znaleźć kolejną okazję\nna rynku memecoinów Solany.',
      'limitDescription': 'Wykorzystano wszystkie 3 darmowe sygnały\ndostępne w ciągu 24 godzin.',
      'cooldownRemaining': 'POZOSTAŁY CZAS PRZERWY',
      'signalsUsed': 'wykorzystane sygnały',
      'generate': 'GENERUJ DARMOWY SYGNAŁ',
      'scanTime': 'Skanowanie AI może potrwać do 5 minut.',
      'todayFree': 'DZISIEJSZY DARMOWY SYGNAŁ',
      'oneFree': 'Dostępny jest jeden darmowy sygnał.',
      'reveal': 'POKAŻ SYGNAŁ',
      'noSignal': 'NIE ZNALEZIONO SYGNAŁU',
      'noSignalDescription': 'AI nie znalazło odpowiedniej okazji.\nDarmowy sygnał nie został wykorzystany.',
      'ok': 'OK',
      'generationError': 'Nie udało się wygenerować sygnału. Spróbuj ponownie.',
      'cooldownMessage': 'Poprzedni darmowy sygnał jest jeszcze w okresie oczekiwania.',
      'scanning': 'SKANOWANIE RYNKU...',
      'scanningDescription': 'AI szuka odpowiedniej okazji\nna rynku memecoinów Solany.',
      'leaveOpen': 'Możesz pozostawić ten ekran otwarty podczas skanowania.',
      'active': 'SYGNAŁ AKTYWNY',
      'expired': 'SYGNAŁ WYGASŁ',
      'entry': 'WEJŚCIE',
      'stopLoss': 'STOP LOSS',
      'takeProfit': 'TAKE PROFIT 1',
      'confidence': 'PEWNOŚĆ AI',
      'viewSignal': 'ZOBACZ SYGNAŁ',
      'risk': 'RYZYKO',
      'token': 'TOKEN',
      'market': 'RYNEK',
      'solanaMeme': 'MEMECOIN SOLANA',
      'dex': 'ZOBACZ W DEXSCREENER',
      'proAccess': 'DOSTĘP PRO AKTYWNY',
      'proSignal': 'SYGNAŁ PRO',
      'generating': 'Generowanie sygnału',
      'unlockEngine': 'Odblokuj pełny silnik sygnałów',
      'proDescription': 'Nielimitowane sygnały, pełna analiza\ni zaawansowane dane rynkowe.',
      'unlockPro': 'ODBLOCKUJ AVEXA PRO',
      'fullAnalysis': 'Pełna analiza sygnałów',
      'alerts': 'Alerty w czasie rzeczywistym',
      'unlimitedSignals': 'Nielimitowane sygnały AI',
      'paywallDescription': 'Uzyskaj nielimitowane sygnały tradingowe AI, pełną analizę i zaawansowane dane rynkowe.',
      'solanaMemePro': 'MEMECOIN SOLANA',
      'proAiSignal': 'PRO  •  SYGNAŁ AI',
    },
    'de': {
      'signals': 'Signale',
      'free': 'KOSTENLOS',
      'freeLimit': 'Bis zu 3 Signale / 24 Std.',
      'pro': 'PRO',
      'unlimited': 'Unbegrenzte KI-Signale',
      'disclaimer': 'Signale sind KI-generierte Marktanalysen,\nkeine Finanzberatung.',
      'cooldownTitle': 'NÄCHSTES SIGNAL VERFÜGBAR IN',
      'cooldownDescription': 'Der nächste kostenlose Scan ist nach Ablauf der Wartezeit verfügbar.',
      'ready': 'BEREIT ZUM SCANNEN',
      'dailyLimit': 'TAGESLIMIT ERREICHT',
      'readyDescription': 'Lass die KI nach dem nächsten passenden\nSolana-Memecoin-Setup suchen.',
      'limitDescription': 'Du hast alle 3 kostenlosen Signale\ninnerhalb von 24 Stunden verwendet.',
      'cooldownRemaining': 'VERBLEIBENDE WARTEZEIT',
      'signalsUsed': 'Signale verwendet',
      'generate': 'KOSTENLOSES SIGNAL ERSTELLEN',
      'scanTime': 'Der KI-Scan kann bis zu 5 Minuten dauern.',
      'todayFree': 'HEUTIGES KOSTENLOSES SIGNAL',
      'oneFree': 'Heute ist ein kostenloses Signal verfügbar.',
      'reveal': 'SIGNAL ANZEIGEN',
      'noSignal': 'KEIN SIGNAL GEFUNDEN',
      'noSignalDescription': 'Die KI hat diesmal kein passendes Setup gefunden.\nDein kostenloses Signal wurde nicht verbraucht.',
      'ok': 'OK',
      'generationError': 'Signal konnte nicht erstellt werden. Bitte erneut versuchen.',
      'cooldownMessage': 'Dein vorheriges kostenloses Signal befindet sich noch in der Wartezeit.',
      'scanning': 'MARKT WIRD GESCANNT...',
      'scanningDescription': 'Die KI sucht nach einem passenden\nSolana-Memecoin-Setup.',
      'leaveOpen': 'Du kannst diesen Bildschirm während des Scans geöffnet lassen.',
      'active': 'SIGNAL AKTIV',
      'expired': 'SIGNAL ABGELAUFEN',
      'entry': 'EINSTIEG',
      'stopLoss': 'STOP LOSS',
      'takeProfit': 'TAKE PROFIT 1',
      'confidence': 'KI-SICHERHEIT',
      'viewSignal': 'SIGNAL ANSEHEN',
      'risk': 'RISIKO',
      'token': 'TOKEN',
      'market': 'MARKT',
      'solanaMeme': 'SOLANA-MEMECOIN',
      'dex': 'AUF DEXSCREENER ANSEHEN',
      'proAccess': 'PRO-ZUGANG AKTIV',
      'proSignal': 'PRO-SIGNAL',
      'generating': 'Signal wird erstellt',
      'unlockEngine': 'Schalte die gesamte Signal-Engine frei',
      'proDescription': 'Unbegrenzte Signale, vollständige Analyse\nund erweiterte Marktdaten.',
      'unlockPro': 'AVEXA PRO FREISCHALTEN',
      'fullAnalysis': 'Vollständige Signalanalyse',
      'alerts': 'Echtzeit-Benachrichtigungen',
      'unlimitedSignals': 'Unbegrenzte KI-Signale',
      'paywallDescription': 'Erhalte unbegrenzte KI-Trading-Signale, vollständige Analysen und erweiterte Marktdaten.',
      'solanaMemePro': 'SOLANA-MEMECOIN',
      'proAiSignal': 'PRO  •  KI-SIGNAL',
    },
    'ja': {
      'signals': 'シグナル',
      'free': '無料',
      'freeLimit': '24時間で最大3件',
      'pro': 'PRO',
      'unlimited': 'AIシグナル無制限',
      'disclaimer': 'シグナルはAIによる市場分析であり、\n投資助言ではありません。',
      'cooldownTitle': '次のシグナルまで',
      'cooldownDescription': 'クールダウン終了後に次の無料スキャンを利用できます。',
      'ready': 'スキャン準備完了',
      'dailyLimit': '本日の上限に到達',
      'readyDescription': 'AIで次のSolanaミームコインの\n取引機会を探しましょう。',
      'limitDescription': '24時間以内に利用できる\n無料シグナル3件を使い切りました。',
      'cooldownRemaining': '残りクールダウン時間',
      'signalsUsed': '件使用済み',
      'generate': '無料シグナルを生成',
      'scanTime': 'AIスキャンには最大5分かかる場合があります。',
      'todayFree': '本日の無料シグナル',
      'oneFree': '本日は無料シグナルを1件利用できます。',
      'reveal': 'シグナルを表示',
      'noSignal': 'シグナルが見つかりません',
      'noSignalDescription': '今回は条件に合う取引機会が見つかりませんでした。\n無料シグナルは消費されていません。',
      'ok': 'OK',
      'generationError': 'シグナルを生成できませんでした。もう一度お試しください。',
      'cooldownMessage': '前回の無料シグナルはまだクールダウン中です。',
      'scanning': '市場をスキャン中...',
      'scanningDescription': 'AIがSolanaミームコインの\n取引機会を探しています。',
      'leaveOpen': 'スキャン中はこの画面を開いたままにできます。',
      'active': 'シグナル有効',
      'expired': 'シグナル期限切れ',
      'entry': 'エントリー',
      'stopLoss': '損切り',
      'takeProfit': '利確 1',
      'confidence': 'AI信頼度',
      'viewSignal': 'シグナルを見る',
      'risk': 'リスク',
      'token': 'トークン',
      'market': '市場',
      'solanaMeme': 'SOLANAミーム',
      'dex': 'DEXSCREENERで見る',
      'proAccess': 'PROアクセス有効',
      'proSignal': 'PROシグナル',
      'generating': 'シグナルを生成中',
      'unlockEngine': 'すべてのシグナル機能を解放',
      'proDescription': '無制限のシグナル、詳細分析、\n高度な市場データ。',
      'unlockPro': 'AVEXA PROを解放',
      'fullAnalysis': 'シグナルの詳細分析',
      'alerts': 'リアルタイム通知',
      'unlimitedSignals': 'AIシグナル無制限',
      'paywallDescription': '無制限のAI取引シグナル、詳細分析、高度な市場データを利用できます。',
      'solanaMemePro': 'SOLANAミーム',
      'proAiSignal': 'PRO  •  AIシグナル',
    },
    'ru': {
      'signals': 'Сигналы',
      'free': 'БЕСПЛАТНО',
      'freeLimit': 'До 3 сигналов / 24 ч',
      'pro': 'PRO',
      'unlimited': 'Неограниченные сигналы ИИ',
      'disclaimer': 'Сигналы — это анализ рынка с помощью ИИ,\nа не финансовая рекомендация.',
      'cooldownTitle': 'ДО СЛЕДУЮЩЕГО СИГНАЛА',
      'cooldownDescription': 'Следующее бесплатное сканирование станет доступно после окончания ожидания.',
      'ready': 'ГОТОВ К СКАНИРОВАНИЮ',
      'dailyLimit': 'ДНЕВНОЙ ЛИМИТ ДОСТИГНУТ',
      'readyDescription': 'Пусть ИИ найдёт следующую подходящую\nвозможность на рынке мемкоинов Solana.',
      'limitDescription': 'Вы использовали все 3 бесплатных сигнала,\nдоступных в течение 24 часов.',
      'cooldownRemaining': 'ОСТАЛОСЬ ОЖИДАТЬ',
      'signalsUsed': 'сигналов использовано',
      'generate': 'СОЗДАТЬ БЕСПЛАТНЫЙ СИГНАЛ',
      'scanTime': 'Сканирование ИИ может занять до 5 минут.',
      'todayFree': 'БЕСПЛАТНЫЙ СИГНАЛ НА СЕГОДНЯ',
      'oneFree': 'Сегодня доступен один бесплатный сигнал.',
      'reveal': 'ПОКАЗАТЬ СИГНАЛ',
      'noSignal': 'СИГНАЛ НЕ НАЙДЕН',
      'noSignalDescription': 'ИИ не нашёл подходящую ситуацию.\nБесплатный сигнал не был использован.',
      'ok': 'OK',
      'generationError': 'Не удалось создать сигнал. Попробуйте ещё раз.',
      'cooldownMessage': 'Предыдущий бесплатный сигнал ещё находится на перезарядке.',
      'scanning': 'СКАНИРОВАНИЕ РЫНКА...',
      'scanningDescription': 'ИИ ищет подходящую возможность\nна рынке мемкоинов Solana.',
      'leaveOpen': 'Можно оставить этот экран открытым во время сканирования.',
      'active': 'СИГНАЛ АКТИВЕН',
      'expired': 'СРОК СИГНАЛА ИСТЁК',
      'entry': 'ВХОД',
      'stopLoss': 'СТОП-ЛОСС',
      'takeProfit': 'ТЕЙК-ПРОФИТ 1',
      'confidence': 'УВЕРЕННОСТЬ ИИ',
      'viewSignal': 'ПОСМОТРЕТЬ СИГНАЛ',
      'risk': 'РИСК',
      'token': 'ТОКЕН',
      'market': 'РЫНОК',
      'solanaMeme': 'МЕМКОИН SOLANA',
      'dex': 'ОТКРЫТЬ В DEXSCREENER',
      'proAccess': 'ДОСТУП PRO АКТИВЕН',
      'proSignal': 'СИГНАЛ PRO',
      'generating': 'Сигнал создаётся',
      'unlockEngine': 'Откройте полный движок сигналов',
      'proDescription': 'Неограниченные сигналы, полный анализ\nи расширенные рыночные данные.',
      'unlockPro': 'ОТКРЫТЬ AVEXA PRO',
      'fullAnalysis': 'Полный анализ сигналов',
      'alerts': 'Уведомления в реальном времени',
      'unlimitedSignals': 'Неограниченные сигналы ИИ',
      'paywallDescription': 'Получите неограниченные торговые сигналы ИИ, полный анализ и расширенные рыночные данные.',
      'solanaMemePro': 'МЕМКОИН SOLANA',
      'proAiSignal': 'PRO  •  СИГНАЛ ИИ',
    },
    'ar': {
      'signals': 'الإشارات',
      'free': 'مجاني',
      'freeLimit': 'حتى 3 إشارات / 24 ساعة',
      'pro': 'PRO',
      'unlimited': 'إشارات ذكاء اصطناعي غير محدودة',
      'disclaimer': 'الإشارات تحليل للسوق بواسطة الذكاء الاصطناعي،\nوليست نصيحة مالية.',
      'cooldownTitle': 'الإشارة التالية متاحة خلال',
      'cooldownDescription': 'سيصبح الفحص المجاني التالي متاحًا بعد انتهاء فترة الانتظار.',
      'ready': 'جاهز للفحص',
      'dailyLimit': 'تم بلوغ الحد اليومي',
      'readyDescription': 'دع الذكاء الاصطناعي يبحث عن فرصة مناسبة\nلعملات الميم على Solana.',
      'limitDescription': 'لقد استخدمت الإشارات المجانية الثلاث\nالمتاحة خلال 24 ساعة.',
      'cooldownRemaining': 'الوقت المتبقي',
      'signalsUsed': 'إشارات مستخدمة',
      'generate': 'إنشاء إشارة مجانية',
      'scanTime': 'قد يستغرق الفحص حتى 5 دقائق.',
      'todayFree': 'إشارة اليوم المجانية',
      'oneFree': 'تتوفر إشارة مجانية واحدة اليوم.',
      'reveal': 'عرض الإشارة',
      'noSignal': 'لم يتم العثور على إشارة',
      'noSignalDescription': 'لم يعثر الذكاء الاصطناعي على فرصة مناسبة هذه المرة.\nلم يتم استهلاك الإشارة المجانية.',
      'ok': 'حسنًا',
      'generationError': 'تعذر إنشاء الإشارة. حاول مرة أخرى.',
      'cooldownMessage': 'لا تزال الإشارة المجانية السابقة في فترة الانتظار.',
      'scanning': 'جارٍ فحص السوق...',
      'scanningDescription': 'يبحث الذكاء الاصطناعي عن فرصة مناسبة\nلعملات الميم على Solana.',
      'leaveOpen': 'يمكنك ترك هذه الشاشة مفتوحة أثناء الفحص.',
      'active': 'الإشارة نشطة',
      'expired': 'انتهت صلاحية الإشارة',
      'entry': 'الدخول',
      'stopLoss': 'وقف الخسارة',
      'takeProfit': 'جني الربح 1',
      'confidence': 'ثقة الذكاء الاصطناعي',
      'viewSignal': 'عرض الإشارة',
      'risk': 'المخاطر',
      'token': 'العملة',
      'market': 'السوق',
      'solanaMeme': 'عملات ميم Solana',
      'dex': 'عرض على DEXSCREENER',
      'proAccess': 'اشتراك PRO نشط',
      'proSignal': 'إشارة PRO',
      'generating': 'جارٍ إنشاء الإشارة',
      'unlockEngine': 'افتح محرك الإشارات الكامل',
      'proDescription': 'إشارات غير محدودة وتحليل كامل\nوبيانات سوق متقدمة.',
      'unlockPro': 'افتح AVEXA PRO',
      'fullAnalysis': 'تحليل كامل للإشارات',
      'alerts': 'تنبيهات فورية',
      'unlimitedSignals': 'إشارات ذكاء اصطناعي غير محدودة',
      'paywallDescription': 'احصل على إشارات تداول غير محدودة وتحليل كامل وبيانات سوق متقدمة.',
      'solanaMemePro': 'عملات ميم Solana',
      'proAiSignal': 'PRO  •  إشارة AI',
    },
    'zh': {
      'signals': '交易信号',
      'free': '免费版',
      'freeLimit': '每24小时最多3个信号',
      'pro': 'PRO',
      'unlimited': '无限 AI 信号',
      'disclaimer': '信号是 AI 生成的市场分析，\n不构成财务建议。',
      'cooldownTitle': '下一个信号可用时间',
      'cooldownDescription': '冷却时间结束后即可进行下一次免费扫描。',
      'ready': '准备扫描',
      'dailyLimit': '已达到每日上限',
      'readyDescription': '让 AI 搜索下一个符合条件的\nSolana Meme 币交易机会。',
      'limitDescription': '你已用完当前24小时内\n可用的3个免费信号。',
      'cooldownRemaining': '剩余冷却时间',
      'signalsUsed': '已使用信号',
      'generate': '生成免费信号',
      'scanTime': 'AI 扫描最多可能需要5分钟。',
      'todayFree': '今日免费信号',
      'oneFree': '今天有一个免费信号可用。',
      'reveal': '显示信号',
      'noSignal': '未找到信号',
      'noSignalDescription': 'AI 本次没有找到符合条件的机会。\n免费信号未被消耗。',
      'ok': '确定',
      'generationError': '无法生成信号，请重试。',
      'cooldownMessage': '上一个免费信号仍处于冷却期。',
      'scanning': '正在扫描市场...',
      'scanningDescription': 'AI 正在寻找符合条件的\nSolana Meme 币交易机会。',
      'leaveOpen': '扫描期间可以保持此页面打开。',
      'active': '信号有效',
      'expired': '信号已过期',
      'entry': '入场价',
      'stopLoss': '止损',
      'takeProfit': '止盈 1',
      'confidence': 'AI 置信度',
      'viewSignal': '查看信号',
      'risk': '风险',
      'token': '代币',
      'market': '市场',
      'solanaMeme': 'SOLANA MEME 币',
      'dex': '在 DEXSCREENER 查看',
      'proAccess': 'PRO 权限已启用',
      'proSignal': 'PRO 信号',
      'generating': '正在生成信号',
      'unlockEngine': '解锁完整信号引擎',
      'proDescription': '无限信号、完整分析\n和高级市场数据。',
      'unlockPro': '解锁 AVEXA PRO',
      'fullAnalysis': '完整信号分析',
      'alerts': '实时提醒',
      'unlimitedSignals': '无限 AI 信号',
      'paywallDescription': '获取无限 AI 交易信号、完整分析和高级市场数据。',
      'solanaMemePro': 'SOLANA MEME 币',
      'proAiSignal': 'PRO  •  AI 信号',
    },
    'es': {
      'signals': 'Señales',
      'free': 'GRATIS',
      'freeLimit': 'Hasta 3 señales / 24 h',
      'pro': 'PRO',
      'unlimited': 'Señales de IA ilimitadas',
      'disclaimer': 'Las señales son análisis de mercado generados por IA,\nno asesoramiento financiero.',
      'cooldownTitle': 'PRÓXIMA SEÑAL DISPONIBLE EN',
      'cooldownDescription': 'El siguiente escaneo gratuito estará disponible al finalizar la espera.',
      'ready': 'LISTO PARA ESCANEAR',
      'dailyLimit': 'LÍMITE DIARIO ALCANZADO',
      'readyDescription': 'Deja que la IA busque la próxima oportunidad\nválida en memecoins de Solana.',
      'limitDescription': 'Has usado las 3 señales gratuitas\ndisponibles en el periodo de 24 horas.',
      'cooldownRemaining': 'TIEMPO DE ESPERA RESTANTE',
      'signalsUsed': 'señales usadas',
      'generate': 'GENERAR SEÑAL GRATIS',
      'scanTime': 'El escaneo de IA puede tardar hasta 5 minutos.',
      'todayFree': 'SEÑAL GRATUITA DE HOY',
      'oneFree': 'Hoy hay una señal gratuita disponible.',
      'reveal': 'MOSTRAR SEÑAL',
      'noSignal': 'NO SE ENCONTRÓ NINGUNA SEÑAL',
      'noSignalDescription': 'La IA no encontró una oportunidad válida esta vez.\nNo se ha consumido tu señal gratuita.',
      'ok': 'OK',
      'generationError': 'No se pudo generar la señal. Inténtalo de nuevo.',
      'cooldownMessage': 'Tu señal gratuita anterior sigue en periodo de espera.',
      'scanning': 'ESCANEANDO EL MERCADO...',
      'scanningDescription': 'La IA está buscando una oportunidad válida\nen memecoins de Solana.',
      'leaveOpen': 'Puedes dejar esta pantalla abierta mientras se escanea.',
      'active': 'SEÑAL ACTIVA',
      'expired': 'SEÑAL CADUCADA',
      'entry': 'ENTRADA',
      'stopLoss': 'STOP LOSS',
      'takeProfit': 'TAKE PROFIT 1',
      'confidence': 'CONFIANZA DE IA',
      'viewSignal': 'VER SEÑAL',
      'risk': 'RIESGO',
      'token': 'TOKEN',
      'market': 'MERCADO',
      'solanaMeme': 'MEMECOIN DE SOLANA',
      'dex': 'VER EN DEXSCREENER',
      'proAccess': 'ACCESO PRO ACTIVO',
      'proSignal': 'SEÑAL PRO',
      'generating': 'Generando señal',
      'unlockEngine': 'Desbloquea el motor completo de señales',
      'proDescription': 'Señales ilimitadas, análisis completo\ny datos de mercado avanzados.',
      'unlockPro': 'DESBLOQUEAR AVEXA PRO',
      'fullAnalysis': 'Análisis completo de señales',
      'alerts': 'Alertas en tiempo real',
      'unlimitedSignals': 'Señales de IA ilimitadas',
      'paywallDescription': 'Obtén señales de trading de IA ilimitadas, análisis completos y datos de mercado avanzados.',
      'solanaMemePro': 'MEMECOIN DE SOLANA',
      'proAiSignal': 'PRO  •  SEÑAL DE IA',
    },
    'pt': {
      'signals': 'Sinais',
      'free': 'GRÁTIS',
      'freeLimit': 'Até 3 sinais / 24 h',
      'pro': 'PRO',
      'unlimited': 'Sinais de IA ilimitados',
      'disclaimer': 'Os sinais são análises de mercado geradas por IA,\nnão aconselhamento financeiro.',
      'cooldownTitle': 'PRÓXIMO SINAL DISPONÍVEL EM',
      'cooldownDescription': 'A próxima análise gratuita estará disponível quando terminar o período de espera.',
      'ready': 'PRONTO PARA ANALISAR',
      'dailyLimit': 'LIMITE DIÁRIO ATINGIDO',
      'readyDescription': 'Deixe a IA procurar a próxima oportunidade\nválida em memecoins da Solana.',
      'limitDescription': 'Utilizou os 3 sinais gratuitos\ndisponíveis no período de 24 horas.',
      'cooldownRemaining': 'TEMPO DE ESPERA RESTANTE',
      'signalsUsed': 'sinais utilizados',
      'generate': 'GERAR SINAL GRÁTIS',
      'scanTime': 'A análise da IA pode demorar até 5 minutos.',
      'todayFree': 'SINAL GRATUITO DE HOJE',
      'oneFree': 'Hoje está disponível um sinal gratuito.',
      'reveal': 'REVELAR SINAL',
      'noSignal': 'NENHUM SINAL ENCONTRADO',
      'noSignalDescription': 'A IA não encontrou uma oportunidade válida desta vez.\nO sinal gratuito não foi utilizado.',
      'ok': 'OK',
      'generationError': 'Não foi possível gerar o sinal. Tente novamente.',
      'cooldownMessage': 'O sinal gratuito anterior ainda está no período de espera.',
      'scanning': 'A ANALISAR O MERCADO...',
      'scanningDescription': 'A IA está à procura de uma oportunidade válida\nem memecoins da Solana.',
      'leaveOpen': 'Pode deixar este ecrã aberto durante a análise.',
      'active': 'SINAL ATIVO',
      'expired': 'SINAL EXPIRADO',
      'entry': 'ENTRADA',
      'stopLoss': 'STOP LOSS',
      'takeProfit': 'TAKE PROFIT 1',
      'confidence': 'CONFIANÇA DA IA',
      'viewSignal': 'VER SINAL',
      'risk': 'RISCO',
      'token': 'TOKEN',
      'market': 'MERCADO',
      'solanaMeme': 'MEMECOIN DA SOLANA',
      'dex': 'VER NO DEXSCREENER',
      'proAccess': 'ACESSO PRO ATIVO',
      'proSignal': 'SINAL PRO',
      'generating': 'A gerar sinal',
      'unlockEngine': 'Desbloqueie o motor completo de sinais',
      'proDescription': 'Sinais ilimitados, análise completa\ne dados de mercado avançados.',
      'unlockPro': 'DESBLOQUEAR AVEXA PRO',
      'fullAnalysis': 'Análise completa dos sinais',
      'alerts': 'Alertas em tempo real',
      'unlimitedSignals': 'Sinais de IA ilimitados',
      'paywallDescription': 'Obtenha sinais de trading de IA ilimitados, análise completa e dados de mercado avançados.',
      'solanaMemePro': 'MEMECOIN DA SOLANA',
      'proAiSignal': 'PRO  •  SINAL DE IA',
    },
  };

  String _t(String key) =>
      _translations[_language]?[key] ??
      _translations['en']![key] ??
      key;

  bool isPro = false;
  bool isLoadingPro = true;
  bool freeUnlocked = false;
  bool isLoadingFree = true;
  bool isLoadingProSignals = false;
  bool isLoadingProFuturesSignals = false;
  bool _isRefillingPro = false;

  int freeSignalsUsed = 0;
  Duration _freeCooldownRemaining = Duration.zero;

  Timer? _signalExpiryTimer;
  Timer? _freeDisplayTimer;

  MemeSignal? freeSignal;
  List<MemeSignal> proSignals = [];
  List<MemeSignal> proFuturesSignals = [];
  Duration _freeSignalRemaining = Duration.zero;

  final FreeSignalGenerationService _freeGenerationService =
      FreeSignalGenerationService.instance;

  StreamSubscription<FreeSignalGenerationState>?
      _freeGenerationSubscription;

  bool get isGeneratingFree => _freeGenerationService.isGenerating;
  int get freeGenerationSeconds => _freeGenerationService.elapsed.inSeconds;

  final Map<String, Duration> _signalRemaining = {};

  late final PageController _proPageController;
  int _proPage = 0;

  late final PageController _futuresPageController;
  int _futuresPage = 0;

  @override
  void initState() {
    super.initState();

    isPro = SubscriptionState.instance.isPro;
    isLoadingPro = SubscriptionState.instance.isLoading;

    SubscriptionState.instance.addListener(
      _onSubscriptionChanged,
    );

    _proPageController = PageController(viewportFraction: .92);
    _futuresPageController = PageController(viewportFraction: .92);

    _freeDisplayTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;
        if (_freeGenerationService.isGenerating ||
            _freeCooldownRemaining > Duration.zero) {
          setState(() {
            if (_freeCooldownRemaining > Duration.zero) {
              _freeCooldownRemaining -= const Duration(seconds: 1);
              if (_freeCooldownRemaining < Duration.zero) {
                _freeCooldownRemaining = Duration.zero;
              }
            }
          });
        }
      },
    );

    _freeGenerationSubscription = _freeGenerationService.stream.listen(
      (state) {
        if (!mounted) return;
        setState(() {
          freeSignalsUsed = state.signalsUsed;
          if (state.signal != null) {
            freeSignal = state.signal;
            freeUnlocked = true;
          }
        });
        if (!state.isGenerating) _handleFreeGenerationFinished(state);
      },
    );

    _loadScreen();
  }

  @override
  void dispose() {
    SubscriptionState.instance.removeListener(
      _onSubscriptionChanged,
    );

    _freeGenerationSubscription?.cancel();
    _freeDisplayTimer?.cancel();
    _signalExpiryTimer?.cancel();
    _proPageController.dispose();
    _futuresPageController.dispose();

    super.dispose();
  }

  void _onSubscriptionChanged() {
    if (!mounted) return;

    final subscription = SubscriptionState.instance;

    final wasPro = isPro;
    final nowPro = subscription.isPro;

    setState(() {
      isPro = nowPro;
      isLoadingPro = subscription.isLoading;

      if (wasPro && !nowPro) {
        proSignals = [];
        proFuturesSignals = [];
        isLoadingProSignals = false;
        isLoadingProFuturesSignals = false;
        _proPage = 0;
      }

      if (!wasPro && nowPro) {
        isLoadingProSignals = true;
        isLoadingProFuturesSignals = true;
      }
    });

    if (!wasPro && nowPro && !subscription.isLoading) {
      Future.wait([
        _loadExistingProSignals(),
        _loadExistingProFuturesSignals(),
      ]).then((_) {
        if (mounted && isPro) {
          _ensureProSignals();
        }
      });
    }
  }

  Future<void> _ensureProSignals() async {
    if (!isPro || isLoadingProSignals || _isRefillingPro) return;

    final activeSignals = await MemeSignalService.instance.getProSignals();
    if (!mounted) return;

    if (activeSignals.length >= 5) {
      if (!_listsEqualById(proSignals, activeSignals)) {
        setState(() => proSignals = activeSignals);
        _updateSignalRemaining();
      }
      return;
    }

    _isRefillingPro = true;
    try {
      var signals = activeSignals;
      while (signals.length < 5) {
        final beforeCount = signals.length;
        await MemeSignalService.instance.requestProSignal(
          timeout: const Duration(seconds: 45),
        );
        signals = await MemeSignalService.instance.getProSignals();
        if (signals.length <= beforeCount) break;
      }

      if (!mounted) return;
      setState(() {
        proSignals = signals;
        if (_proPage >= proSignals.length && proSignals.isNotEmpty) {
          _proPage = proSignals.length - 1;
        }
      });
      _updateSignalRemaining();
    } catch (e) {
      debugPrint('PRO AUTO REFILL ERROR: $e');
    } finally {
      _isRefillingPro = false;
    }
  }

  bool _listsEqualById(List<MemeSignal> a, List<MemeSignal> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<void> _refreshFreeCooldown() async {
    try {
      final remaining =
          await MemeSignalService.instance.getFreeCooldownRemaining();
      if (!mounted) return;
      setState(() => _freeCooldownRemaining = remaining);
    } catch (e) {
      debugPrint('FREE COOLDOWN ERROR: $e');
    }
  }

  String _formatCooldown(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _generateFreeSignal() async {
    if (_freeGenerationService.isGenerating || freeSignalsUsed >= 3) return;
    if (_freeCooldownRemaining > Duration.zero) {
      _showFreeCooldown();
      return;
    }

    setState(() {
      freeUnlocked = false;
      freeSignal = null;
    });

    try {
      await _freeGenerationService.start();
    } on FreeSignalCooldownException {
      if (!mounted) return;
      await _refreshFreeCooldown();
      _showFreeCooldown();
    } on FreeSignalLimitException {
      if (!mounted) return;
      setState(() => freeSignalsUsed = 3);
    } catch (e) {
      debugPrint('FREE SIGNAL GENERATION ERROR: $e');
      if (!mounted) return;
      _showFreeGenerationError();
    }
  }

  void _handleFreeGenerationFinished(FreeSignalGenerationState state) {
    if (!mounted) return;
    if (state.errorType == 'not_found') {
      _showFreeGenerationFailed();
      return;
    }
    if (state.errorType == 'cooldown') {
      _showFreeCooldown();
      return;
    }
    if (state.errorType == 'error') {
      _showFreeGenerationError();
      return;
    }
    if (state.signal != null) {
      setState(() {
        freeSignal = state.signal;
        freeSignalsUsed = state.signalsUsed;
        freeUnlocked = true;
      });
    }
  }

  void _startSignalExpiryTimer() {
    _signalExpiryTimer?.cancel();
    _updateSignalRemaining();
    _signalExpiryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) _updateSignalRemaining();
      },
    );
  }

  void _updateSignalRemaining() {
    final now = DateTime.now();
    final updated = <String, Duration>{};
    bool hasExpiredPro = false;

    if (freeSignal != null && freeSignal!.expiresAt != null) {
      final remaining = freeSignal!.expiresAt!.difference(now);
      updated[freeSignal!.id] =
          remaining.isNegative ? Duration.zero : remaining;
    }

    for (final signal in proSignals) {
      if (signal.expiresAt == null) continue;
      final remaining = signal.expiresAt!.difference(now);
      if (remaining <= Duration.zero) hasExpiredPro = true;
      updated[signal.id] =
          remaining.isNegative ? Duration.zero : remaining;
    }

    for (final signal in proFuturesSignals) {
      if (signal.expiresAt == null) continue;

      final remaining = signal.expiresAt!.difference(now);

      updated[signal.id] =
          remaining.isNegative ? Duration.zero : remaining;
    }

    if (!mounted) return;
    setState(() {
      _signalRemaining
        ..clear()
        ..addAll(updated);
    });

    if (hasExpiredPro && isPro && !_isRefillingPro) _ensureProSignals();
  }

  void _showFreeCooldown() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colors.elevatedCard,
        behavior: SnackBarBehavior.floating,
        content: Text(
          _t('cooldownMessage'),
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  void _showFreeGenerationFailed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, color: neonBlue, size: 38),
            const SizedBox(height: 15),
            Text(
              _t('noSignal'),
              style: GoogleFonts.poppins(
                color: colors.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _t('noSignalDescription'),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 10,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  _t('ok'),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFreeGenerationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colors.elevatedCard,
        behavior: SnackBarBehavior.floating,
        content: Text(
          _t('generationError'),
          style: GoogleFonts.poppins(
            color: colors.primaryText,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Future<void> _loadScreen() async {

    await SubscriptionState.instance.refresh();

    if (!mounted) return;

    await _loadSignals();

  }

  Future<void> _loadSignals() async {
    await Future.wait([
      _loadFreeSignal(),
      _loadFreeUsage(),
      _loadExistingProSignals(),
      _loadExistingProFuturesSignals(),
      _refreshFreeCooldown(),
    ]);

    if (!mounted) return;

    _startSignalExpiryTimer();

    if (isPro) _ensureProSignals();
  }

  Future<void> _loadFreeSignal() async {
    if (_freeGenerationService.isGenerating) {
      if (!mounted) return;
      setState(() {
        isLoadingFree = false;
        freeSignal = null;
      });
      return;
    }

    if (mounted) setState(() => isLoadingFree = true);
    try {
      final signal =
          await MemeSignalService.instance.getLatestFreeSignal();
      if (!mounted) return;
      setState(() {
        freeSignal = signal;
        isLoadingFree = false;
      });
    } catch (e) {
      debugPrint('FREE MEME SIGNAL ERROR: $e');
      if (!mounted) return;
      setState(() {
        freeSignal = null;
        isLoadingFree = false;
      });
    }
  }

  Future<void> _loadFreeUsage() async {
    try {
      final used = await MemeSignalService.instance.getFreeSignalsUsed();
      if (!mounted) return;
      setState(() => freeSignalsUsed = used.clamp(0, 3));
    } catch (e) {
      debugPrint('FREE USAGE ERROR: $e');
    }
  }

  
  Future<void> _loadExistingProSignals() async {
    if (!isPro) {
      if (mounted) {
        setState(() {
          isLoadingProSignals = false;
        });
      }
      return;
    }

    if (isLoadingProSignals && _isRefillingPro) return;

    try {
      final signals = await MemeSignalService.instance.getProSignals();

      if (!mounted) return;

      setState(() {
        proSignals = signals;
        isLoadingProSignals = false;

        if (_proPage >= proSignals.length && proSignals.isNotEmpty) {
          _proPage = proSignals.length - 1;
        }

        if (proSignals.isEmpty) _proPage = 0;
      });

      _updateSignalRemaining();
    } catch (e) {
      debugPrint('PRO EXISTING SIGNALS ERROR: $e');

      if (!mounted) return;

      setState(() {
        proSignals = [];
        isLoadingProSignals = false;
        _proPage = 0;
      });
    }
  }

  Future<void> _loadExistingProFuturesSignals() async {
    if (!isPro) {
      if (!mounted) return;

      setState(() {
        proFuturesSignals = [];
        isLoadingProFuturesSignals = false;
      });

      return;
    }

    if (mounted) {
      setState(() => isLoadingProFuturesSignals = true);
    }

    try {
      final rows =
          await SignalService.getActiveFuturesSignals(limit: 5);

      final signals = rows
          .map((row) => MemeSignal.fromMap(row))
          .where((signal) => !signal.isExpired)
          .toList();

      if (!mounted) return;

      if (!mounted) return;

      setState(() {
        proFuturesSignals = signals;
        isLoadingProFuturesSignals = false;

        if (_futuresPage >= signals.length) {
          _futuresPage = signals.isEmpty ? 0 : signals.length - 1;
        }
      });

      if (_futuresPageController.hasClients) {
        _futuresPageController.jumpToPage(_futuresPage);
      }
    } catch (e) {
      debugPrint('FUTURES PRO SIGNALS ERROR: $e');

      if (!mounted) return;

      setState(() {
        proFuturesSignals = [];
        isLoadingProFuturesSignals = false;
      });
    }
  }


  Future<void> _refreshSignals() async {

    await SubscriptionState.instance.refresh();

    if (!mounted) return;

    await _loadSignals();

  }

  void _unlockFreeSignal() {
    if (freeSignal == null) return;
    setState(() => freeUnlocked = true);
  }

  void _showProPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SubscriptionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: neonBlue,
          backgroundColor: colors.card,
          onRefresh: _refreshSignals,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPageHeader(title: _t('signals')),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  title: _t('free'),
                  subtitle: _t('freeLimit'),
                  color: neonBlue,
                  icon: Icons.lock_open_rounded,
                ),
                const SizedBox(height: 14),
                _buildFreeSection(),
                const SizedBox(height: 34),
                _buildSectionTitle(
                  title: _t('pro'),
                  subtitle: _t('unlimited'),
                  color: neonBlue,
                  icon: Icons.auto_awesome_rounded,
                ),
                const SizedBox(height: 14),
                _buildProSection(),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    _t('disclaimer'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colors.mutedText.withOpacity(.55),
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(.09),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: color.withOpacity(.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 11),
                const SizedBox(width: 5),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeSection() {
    if (isLoadingFree) return _buildFreeLoading();
    if (freeSignal == null) return _buildFreeEmpty();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: neonBlue.withOpacity(.25)),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.055),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      child: freeUnlocked ? _buildUnlockedFree() : _buildLockedFree(),
    );
  }

  Widget _buildFreeLoading() {
    return Container(
      height: 360,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: neonBlue),
      ),
    );
  }

  Widget _buildFreeEmpty() {
    if (isGeneratingFree) return _buildFreeGenerating();

    final isCoolingDown = _freeCooldownRemaining > Duration.zero;
    final canGenerate = freeSignalsUsed < 3 && !isCoolingDown;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 32, 25, 28),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: neonBlue.withOpacity(.22)),
        boxShadow: [
          BoxShadow(color: neonBlue.withOpacity(.045), blurRadius: 30),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.09),
              shape: BoxShape.circle,
              border: Border.all(color: neonBlue.withOpacity(.20)),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: neonBlue,
              size: 29,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isCoolingDown
                ? _t('cooldownTitle')
                : canGenerate
                    ? _t('ready')
                    : _t('dailyLimit'),
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isCoolingDown
                ? _t('cooldownDescription')
                : canGenerate
                    ? _t('readyDescription')
                    : _t('limitDescription'),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 10,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (isCoolingDown) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: neonBlue.withOpacity(.25)),
              ),
              child: Column(
                children: [
                  Text(
                    _t('cooldownRemaining'),
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatCooldown(_freeCooldownRemaining),
                    style: GoogleFonts.poppins(
                      color: neonBlue,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border.withOpacity(.65)),
            ),
            child: Text(
              '$freeSignalsUsed / 3 ${_t('signalsUsed')}',
              style: GoogleFonts.poppins(
                color: neonBlue,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (canGenerate) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _generateFreeSignal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _t('generate'),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              _t('scanTime'),
              style: GoogleFonts.poppins(
                color: colors.mutedText,
                fontSize: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLockedFree() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: _buildSignalCard(
              signal: freeSignal!,
              color: neonBlue,
              compact: true,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: colors.background.withOpacity(.55),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: neonBlue.withOpacity(.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: neonBlue.withOpacity(.25)),
                    boxShadow: [
                      BoxShadow(color: neonBlue.withOpacity(.12), blurRadius: 25),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: neonBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _t('todayFree'),
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _t('oneFree'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _unlockFreeSignal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_rounded, size: 17),
                        const SizedBox(width: 8),
                        Text(
                          _t('reveal'),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .6,
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
      ],
    );
  }

  Widget _buildUnlockedFree() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: _buildSignalCard(
        signal: freeSignal!,
        color: neonBlue,
        compact: true,
        onViewDetails: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SignalDetailScreen(signal: freeSignal!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProSection() {
    if (isLoadingPro) return _buildLoadingPro();
    if (!isPro) return _buildLockedPro();
    if (isLoadingProSignals) return _buildLoadingPro();
    return _buildUnlockedPro();
  }

  Widget _buildLockedPro() {
    return Container(
      width: double.infinity,
      height: 440,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: neonBlue.withOpacity(.30)),
        boxShadow: [
          BoxShadow(
            color: neonBlue.withOpacity(.07),
            blurRadius: 35,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: _buildProPreview(),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: colors.background.withOpacity(.62),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: neonBlue.withOpacity(.09),
                      shape: BoxShape.circle,
                      border: Border.all(color: neonBlue.withOpacity(.30)),
                      boxShadow: [
                        BoxShadow(color: neonBlue.withOpacity(.12), blurRadius: 30),
                      ],
                    ),
                    child: const Icon(Icons.lock_rounded, color: neonBlue, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'AVEXA PRO',
                    style: GoogleFonts.poppins(
                      color: neonBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _t('unlockEngine'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _t('proDescription'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colors.secondaryText,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showProPaywall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: neonBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        _t('unlockPro'),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedPro() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: neonBlue.withOpacity(.28)),
        boxShadow: [
          BoxShadow(color: neonBlue.withOpacity(.06), blurRadius: 32),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.045),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: neonBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  _t('proAccess'),
                  style: GoogleFonts.poppins(
                    color: neonBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.auto_awesome_rounded, color: neonBlue, size: 15),
              ],
            ),
          ),
          _buildProMemeCarousel(),
          Padding(
            padding: const EdgeInsets.only(bottom: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == _proPage ? 18 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: index == _proPage
                        ? neonBlue
                        : colors.border.withOpacity(.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.show_chart_rounded,
                  color: neonBlue,
                  size: 17,
                ),
                const SizedBox(width: 9),
                Text(
                  'OKX FUTURES',
                  style: GoogleFonts.poppins(
                    color: neonBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  'PRO',
                  style: GoogleFonts.poppins(
                    color: colors.secondaryText,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          _buildProFuturesSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


  Widget _buildProMemeCarousel() {
    if (proSignals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.border.withOpacity(.55),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: neonBlue,
                size: 27,
              ),
              const SizedBox(height: 10),
              Text(
                'PRO MEME signals are being prepared',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pageCount = proSignals.length;

    return Column(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _proPageController,
            itemCount: pageCount,
            onPageChanged: (index) {
              if (!mounted) return;
              setState(() => _proPage = index);
            },
            itemBuilder: (context, index) {
              final signal = proSignals[index];

              return Padding(
                padding: const EdgeInsets.all(14),
                child: _buildSignalCard(
                  signal: signal,
                  color: neonBlue,
                  compact: true,
                  onViewDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SignalDetailScreen(signal: signal),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 17),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _proPage ? 18 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: index == _proPage
                      ? neonBlue
                      : colors.border.withOpacity(.35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  
  Widget _buildProFuturesSection() {
    if (isLoadingProFuturesSignals) {
      return const Padding(
        padding: EdgeInsets.all(25),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: neonBlue,
          ),
        ),
      );
    }

    if (proFuturesSignals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.border.withOpacity(.55),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: colors.mutedText,
                size: 27,
              ),
              const SizedBox(height: 10),
              Text(
                'No active Futures signals',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: colors.secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pageCount = proFuturesSignals.length;

    return Column(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _futuresPageController,
            itemCount: pageCount,
            onPageChanged: (index) {
              if (!mounted) return;
              setState(() => _futuresPage = index);
            },
            itemBuilder: (context, index) {
              final signal = proFuturesSignals[index];

              return Padding(
                padding: const EdgeInsets.all(14),
                child: _buildSignalCard(
                  signal: signal,
                  color: neonBlue,
                  compact: true,
                  onViewDetails: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SignalDetailScreen(signal: signal),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _futuresPage ? 18 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: index == _futuresPage
                      ? neonBlue
                      : colors.border.withOpacity(.35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildProEmptyCard({required Color color, required int index}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, color: color.withOpacity(.5), size: 35),
          const SizedBox(height: 15),
          Text(
            '${_t('proSignal')} ${index + 1}',
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _t('generating'),
            style: GoogleFonts.poppins(color: colors.mutedText, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _displaySignalSymbol(MemeSignal signal) {
    if (signal.market.toUpperCase() != 'FUTURES') {
      return signal.symbol;
    }

    // OKX: NOT-USDT-SWAP -> NOT
    return signal.symbol.split('-').first.toUpperCase();
  }

  Widget _buildSignalCard({
    required MemeSignal signal,
    required Color color,
    bool compact = false,
    VoidCallback? onViewDetails,
  }) {
    final displaySymbol = _displaySignalSymbol(signal);
    final isFutures = signal.market.toUpperCase() == 'FUTURES';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(.10),
                  border: Border.all(color: color.withOpacity(.20)),
                ),
                child: signal.imageUrl != null && signal.imageUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          signal.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return isFutures
                                ? Center(
                                    child: Text(
                                      displaySymbol.length > 4
                                          ? displaySymbol.substring(0, 4)
                                          : displaySymbol,
                                      style: GoogleFonts.poppins(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.currency_bitcoin_rounded,
                                    color: color,
                                    size: 25,
                                  );
                          },
                        ),
                      )
                    : isFutures
                        ? Center(
                            child: Text(
                              displaySymbol.length > 4
                                  ? displaySymbol.substring(0, 4)
                                  : displaySymbol,
                              style: GoogleFonts.poppins(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.currency_bitcoin_rounded,
                            color: color,
                            size: 25,
                          ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displaySymbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: colors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${signal.market.toUpperCase() == 'FUTURES' ? 'OKX FUTURES' : _t('solanaMeme')}  •  ${signal.timeframe}',
                      style: GoogleFonts.poppins(
                        color: colors.mutedText,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: neonGreen.withOpacity(.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  signal.direction,
                  style: GoogleFonts.poppins(
                    color: neonGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSignalCountdown(signal),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                _t('confidence'),
                style: GoogleFonts.poppins(
                  color: colors.mutedText,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${signal.confidence}%',
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: signal.confidence / 100,
              backgroundColor: colors.border.withOpacity(.35),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 14),
          _signalPriceRow(
            title: _t('entry'),
            value: _formatPrice(signal.entryPrice),
            color: color,
          ),
          const SizedBox(height: 7),
          _signalPriceRow(
            title: _t('stopLoss'),
            value: _formatPrice(signal.stopLoss),
            color: neonRed,
          ),
          const SizedBox(height: 7),
          _signalPriceRow(
            title: _t('takeProfit'),
            value: _formatPrice(signal.takeProfit1),
            color: neonGreen,
          ),
          if (compact && onViewDetails != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: onViewDetails,
                style: OutlinedButton.styleFrom(
                  foregroundColor: neonBlue,
                  side: BorderSide(color: neonBlue.withOpacity(.30)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _t('viewSignal'),
                      style: GoogleFonts.poppins(
                        color: neonBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: neonBlue, size: 17),
                  ],
                ),
              ),
            ),
          ],
          if (!compact) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _smallInfoBox(title: _t('risk'), value: signal.riskLevel),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _smallInfoBox(
                    title: 'R:R',
                    value: signal.riskReward != null
                        ? '1:${signal.riskReward!.toStringAsFixed(2)}'
                        : '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _previewRow(_t('token'), signal.shortTokenAddress),
            const SizedBox(height: 8),
            _previewRow(_t('market'), _t('solanaMeme')),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(.07),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(
                  _t('dex'),
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _signalPriceRow({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(.60)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: colors.mutedText,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfoBox({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(.60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: colors.mutedText,
              fontSize: 7,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == 0) return '—';
    if (price >= 1000) return price.toStringAsFixed(2);
    if (price >= 1) return price.toStringAsFixed(4);
    if (price >= 0.01) return price.toStringAsFixed(6);
    return price.toStringAsFixed(10).replaceFirst(RegExp(r'0+$'), '');
  }

  Widget _previewRow(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.border.withOpacity(.65)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: colors.mutedText,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProPreview() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: neonBlue.withOpacity(.10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: neonBlue, size: 27),
              ),
              const SizedBox(width: 13),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('solanaMemePro'),
                    style: GoogleFonts.poppins(
                      color: colors.primaryText,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _t('proAiSignal'),
                    style: GoogleFonts.poppins(color: colors.mutedText, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border.withOpacity(.45)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingPro() {
    return Container(
      height: 440,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: neonBlue),
      ),
    );
  }

  Widget _buildProPaywall() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: colors.mutedText.withOpacity(.35),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: neonBlue.withOpacity(.10),
              shape: BoxShape.circle,
              border: Border.all(color: neonBlue.withOpacity(.25)),
              boxShadow: [
                BoxShadow(color: neonBlue.withOpacity(.10), blurRadius: 25),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: neonBlue, size: 34),
          ),
          const SizedBox(height: 20),
          Text(
            _t('unlockPro'),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _t('paywallDescription'),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          _paywallFeature(Icons.bolt_rounded, _t('unlimitedSignals')),
          const SizedBox(height: 8),
          _paywallFeature(Icons.analytics_rounded, _t('fullAnalysis')),
          const SizedBox(height: 8),
          _paywallFeature(Icons.notifications_active_rounded, _t('alerts')),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: neonBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _t('unlockPro'),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paywallFeature(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.border.withOpacity(.55)),
      ),
      child: Row(
        children: [
          Icon(icon, color: neonBlue, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: colors.secondaryText,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeGenerating() {
    final minutes = (freeGenerationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (freeGenerationSeconds % 60).toString().padLeft(2, '0');
    final progress = (freeGenerationSeconds / 300).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 32, 25, 30),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: neonBlue.withOpacity(.25)),
        boxShadow: [
          BoxShadow(color: neonBlue.withOpacity(.055), blurRadius: 30),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: const AlwaysStoppedAnimation<Color>(neonBlue),
              backgroundColor: colors.border.withOpacity(.35),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _t('scanning'),
            style: GoogleFonts.poppins(
              color: colors.primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _t('scanningDescription'),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: colors.secondaryText,
              fontSize: 10,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: progress,
              backgroundColor: colors.border.withOpacity(.35),
              valueColor: const AlwaysStoppedAnimation<Color>(neonBlue),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            '$minutes:$seconds / 05:00',
            style: GoogleFonts.poppins(
              color: neonBlue,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _t('leaveOpen'),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: colors.mutedText, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalCountdown(MemeSignal signal) {
    final remaining = _signalRemaining[signal.id];
    if (signal.expiresAt == null) return const SizedBox.shrink();

    final duration = remaining ?? signal.expiresAt!.difference(DateTime.now());
    final isExpired = duration <= Duration.zero;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: isExpired ? neonRed.withOpacity(.07) : neonBlue.withOpacity(.07),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: isExpired ? neonRed.withOpacity(.18) : neonBlue.withOpacity(.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isExpired ? neonRed : neonBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isExpired ? neonRed : neonBlue).withOpacity(.35),
                  blurRadius: 7,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isExpired ? _t('expired') : _t('active'),
            style: GoogleFonts.poppins(
              color: isExpired ? neonRed : neonBlue,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
          const Spacer(),
          if (!isExpired)
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: neonBlue, size: 14),
                const SizedBox(width: 5),
                Text(
                  '$minutes:$seconds',
                  style: GoogleFonts.poppins(
                    color: colors.primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            )
          else
            Text(
              _t('expired'),
              style: GoogleFonts.poppins(
                color: neonRed,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}