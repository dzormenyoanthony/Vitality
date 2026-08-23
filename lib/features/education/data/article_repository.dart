import 'article.dart';

const _source = 'American Heart Association — heart.org';
final _reviewed = DateTime(2026, 6, 1);

/// Static, read-only educational content (PROJECT_SPEC.md §15, §16).
///
/// This is general information only, sourced from the user-approved
/// authoritative source (American Heart Association). It deliberately
/// contains no numeric blood-pressure classification thresholds
/// (normal/elevated/stage 1/stage 2/crisis) — that remains gated behind a
/// separate, not-yet-approved decision (§14) about classifying a user's own
/// readings, and is out of scope here regardless of source.
///
/// Content isn't user data, so it's a plain in-memory list rather than a
/// database table — there's nothing to persist, sync, or mutate.
abstract final class ArticleRepository {
  static List<Article> all() => _articles;

  static Article? byId(String id) {
    for (final article in _articles) {
      if (article.id == id) return article;
    }
    return null;
  }

  static final List<Article> _articles = [
    Article(
      id: 'what-is-blood-pressure',
      category: ArticleCategory.basics,
      title: 'What systolic and diastolic actually measure',
      summary: 'The two numbers in a blood pressure reading, explained.',
      readTimeMinutes: 5,
      reviewed: _reviewed,
      source: _source,
      body: [
        'Blood pressure is the force your blood exerts against the walls of '
            'your arteries as your heart pumps. It is written as two numbers, '
            'such as 120/80, and measured in millimeters of mercury (mmHg).',
        'The first, higher number is systolic pressure — the force in your '
            'arteries while your heart muscle is contracting and pushing blood '
            'out. The second, lower number is diastolic pressure — the force '
            'in your arteries while your heart is resting between beats.',
        'Both numbers matter. Your healthcare professional looks at the two '
            'together, along with your personal history, to help interpret '
            'what your readings mean for you — a single reading in isolation '
            'is rarely the full picture.',
        'Vitaly records both numbers so you can track them over time and '
            'share consistent, accurate data with your healthcare '
            'professional. Vitaly does not interpret, diagnose, or classify '
            'your readings.',
      ],
    ),
    Article(
      id: 'lifestyle-factors',
      category: ArticleCategory.basics,
      title: 'Lifestyle factors associated with blood pressure',
      summary: 'General factors that can influence blood pressure over time.',
      readTimeMinutes: 4,
      reviewed: _reviewed,
      source: _source,
      body: [
        'A number of everyday factors are generally associated with blood '
            'pressure, including physical activity, dietary sodium intake, '
            'body weight, alcohol consumption, tobacco use, sleep quality, '
            'and stress.',
        'These associations are general and vary from person to person. '
            'They are not a treatment plan, and this information should not '
            'be used to decide whether to start, stop, or change any '
            'medication or lifestyle regimen on your own.',
        'If you are interested in how lifestyle changes might apply to your '
            'own health, a healthcare professional can help you set '
            'realistic, personalized goals.',
      ],
    ),
    Article(
      id: 'medication-adherence',
      category: ArticleCategory.basics,
      title: 'Why taking blood pressure medication as prescribed matters',
      summary: 'General information on medication adherence.',
      readTimeMinutes: 3,
      reviewed: _reviewed,
      source: _source,
      body: [
        'For people who are prescribed blood pressure medication, taking it '
            'consistently and as directed is generally an important part of '
            'managing blood pressure over time. Missing doses or stopping '
            'abruptly can affect how well treatment works.',
        'If a medication causes side effects, seems ineffective, or you are '
            'considering changing how you take it, talk to your prescribing '
            'healthcare professional first. Never stop or change a '
            'medication dose based on an app.',
        'Vitaly does not track medications in this version and does not '
            'provide medication advice. Its role is limited to helping you '
            'keep a consistent record of your readings to discuss with your '
            'provider.',
      ],
    ),
    Article(
      id: 'how-to-measure-at-home',
      category: ArticleCategory.measuringWell,
      title: 'How to take a reading at home',
      summary: 'Cuff position, posture, and timing for a consistent reading.',
      readTimeMinutes: 4,
      reviewed: _reviewed,
      source: _source,
      body: [
        'Home readings are most useful when taken the same way each time. '
            'Consistency in posture, timing, and cuff placement reduces '
            'variation that has nothing to do with your blood pressure.',
        'Before you measure: avoid caffeine, smoking, and exercise for 30 '
            'minutes beforehand. Empty your bladder, then sit quietly for '
            'about five minutes before starting.',
        'While you measure: sit with your back supported and both feet flat '
            'on the floor — don\'t cross your legs. Rest your arm on a table '
            'so the cuff sits level with your heart, with the cuff\'s lower '
            'edge about 2 cm above the elbow crease, snug but not tight, '
            'directly on skin rather than over clothing.',
        'Stay still and avoid talking while the cuff inflates. If your '
            'device allows it, take two or three readings a minute or so '
            'apart and record each one rather than a single average — '
            'individual readings can vary.',
      ],
    ),
    Article(
      id: 'why-readings-vary',
      category: ArticleCategory.measuringWell,
      title: 'Why readings vary through the day',
      summary: 'Circadian pattern, activity, and stress can all shift a reading.',
      readTimeMinutes: 3,
      reviewed: _reviewed,
      source: _source,
      body: [
        'Blood pressure naturally rises and falls throughout the day. It '
            'tends to be lower during sleep, rises in the morning, and can '
            'shift with activity, stress, temperature, posture, and recent '
            'food, caffeine, or tobacco use.',
        'Because of this natural variation, a single reading is a snapshot, '
            'not a complete picture. Measuring at a similar time each day — '
            'for example, morning and evening — makes your readings easier '
            'to compare to each other over time.',
        'If one reading looks unusually different from your usual pattern, '
            'it can help to measure again after resting rather than assuming '
            'it reflects a real change, and to mention any pattern you '
            'notice to your healthcare professional.',
      ],
    ),
    Article(
      id: 'choosing-a-monitor',
      category: ArticleCategory.measuringWell,
      title: 'Choosing and checking a home monitor',
      summary: 'Validation, cuff size, and calibration basics.',
      readTimeMinutes: 6,
      reviewed: _reviewed,
      source: _source,
      body: [
        'An upper-arm cuff monitor is generally preferred over a wrist or '
            'finger device for home use, since upper-arm readings tend to be '
            'more consistent.',
        'Cuff size matters: a cuff that is too small or too large for your '
            'arm can distort a reading. Check the manufacturer\'s sizing '
            'guide, and ask your healthcare professional or pharmacist for '
            'help choosing a properly fitted cuff if you\'re unsure.',
        'Look for a monitor that has been independently validated for '
            'clinical accuracy — many manufacturers state this on the '
            'packaging or website. It\'s also reasonable to periodically '
            'check your monitor\'s accuracy against a healthcare provider\'s '
            'device, and to replace or recalibrate it if your provider '
            'suggests doing so.',
      ],
    ),
    Article(
      id: 'working-with-your-clinician',
      category: ArticleCategory.workingWithClinician,
      title: 'Sharing your log with your clinician',
      summary: 'What to bring to an appointment and when to seek care sooner.',
      readTimeMinutes: 4,
      reviewed: _reviewed,
      source: _source,
      body: [
        'A consistent home log can give your healthcare professional a '
            'fuller picture than a single in-office reading, since it shows '
            'patterns over time rather than one moment. Bringing your '
            'readings, the monitor you used, your current medications, and '
            'any questions you have to your appointment can help make the '
            'most of your visit.',
        'Vitaly\'s history and trends screens are designed to make it easy '
            'to review and share your recorded readings and averages with '
            'your provider.',
        'This information is general and does not replace personalized '
            'medical advice. If a reading feels unusual for you, or you '
            'experience symptoms such as chest pain, severe headache, '
            'shortness of breath, vision changes, or confusion, contact a '
            'healthcare professional or emergency services promptly rather '
            'than relying on an app.',
      ],
    ),
  ];
}
