import 'package:flutter/material.dart';

const educationLevels = [
  'Still in school',
  'High school completed',
  'Diploma / certificate',
  'College or university (in progress)',
  'Degree completed',
  'Self-taught / no formal education',
];

const experienceLevels = [
  'No experience yet',
  'A little (projects, volunteering)',
  '1-3 years',
  '3+ years',
];

const interestOptions = [
  'Technology',
  'Design',
  'Creative / Visual',
  'Video & Audio',
  'Writing',
  'Numbers & Data',
  'Business & Sales',
  'Helping people',
  'Automation & AI',
];

const allSkills = [
  'HTML',
  'CSS',
  'JavaScript',
  'Git',
  'Python',
  'SQL',
  'Excel/Sheets',
  'Video editing',
  'Color grading',
  'Motion graphics',
  'Photoshop/Photo editing',
  'Figma/UI design',
  'Typography',
  'Writing',
  'Copywriting',
  'SEO',
  'Social media',
  'Email marketing',
  'Analytics',
  'Communication',
  'Customer support',
  'Research',
  'Data visualization',
  'Statistics',
  'Prompt writing/AI tools',
  'No-code automation',
  'Problem solving',
  'Time management',
];

const hoursOptions = ['Under 3 hours', '3-6 hours', '6-10 hours', '10+ hours'];

const goalOptions = [
  'Get my first job',
  'Find freelance clients',
  'Earn extra income alongside study or work',
  'Change careers',
  'Grow in my current field',
];

const appStatuses = ['Applied', 'Interview', 'Offer', 'Rejected'];
const jobTypes = ['All', 'Job', 'Internship', 'Freelance', 'Apprenticeship'];

class Lesson {
  final String id, title, resource, url, practice;
  const Lesson(this.id, this.title, this.resource, this.url, this.practice);
}

class Module {
  final String title, goal;
  final List<Lesson> lessons;
  Module(this.title, this.goal, this.lessons);
}

class QuizQ {
  final String q;
  final List<String> options;
  final int answer;
  final String why;
  QuizQ(this.q, this.options, this.answer, this.why);
}

class Career {
  final String id, title, summary, beginnerPath, firstIncome;
  final IconData icon;
  final List<String> skills, interests, projects, interviewQs, searchTerms;
  final bool beginnerFriendly;
  final List<Module> coreModules;
  final List<QuizQ> quiz;

  Career({
    required this.id,
    required this.title,
    required this.summary,
    required this.beginnerPath,
    required this.firstIncome,
    required this.icon,
    required this.skills,
    required this.interests,
    required this.projects,
    required this.interviewQs,
    required this.searchTerms,
    required this.beginnerFriendly,
    required this.coreModules,
    required this.quiz,
  });

  List<Module> get modules => [...coreModules, _getPaid(id)];
  List<Lesson> get lessons => [for (final m in modules) ...m.lessons];
}

Module _getPaid(String id) => Module(
      'Get paid: portfolio, applications, interviews',
      'Turn your skills into real opportunities.',
      [
        Lesson('$id-7', 'Package your best work into a portfolio',
            'In this app: Resume tab > Portfolio', '',
            'Add 2-3 real projects you actually completed, each with a short honest description and a link if you have one.'),
        Lesson('$id-8', 'Find and apply to your first 5 opportunities',
            'In this app: Jobs tab', '',
            'Save 5 opportunities that fit, read the requirements, and apply to the ones you choose. You decide where to apply.'),
        Lesson('$id-9', 'Practise interviews and client pitches',
            'In this app: Assistant tab', '',
            'Answer 4 common questions out loud, using real examples from your own practice projects.'),
      ],
    );

Career? careerById(String? id) {
  if (id == null) return null;
  for (final c in careers) {
    if (c.id == id) return c;
  }
  return null;
}

final List<Career> careers = [
  Career(
    id: 'web',
    title: 'Web Developer',
    summary: 'Build websites and web apps for businesses, clients or a company team.',
    beginnerPath:
        'You do not need a degree to start. Build 3 small sites, publish them free on GitHub Pages and use them as your portfolio. Many junior roles and freelance clients look at working projects first.',
    firstIncome:
        'Offer simple one-page sites to local shops, or apply for junior and internship roles and small freelance fixes once you have 3 published projects.',
    icon: Icons.code_rounded,
    skills: ['HTML', 'CSS', 'JavaScript', 'Git', 'Problem solving', 'Communication'],
    interests: ['Technology', 'Design'],
    beginnerFriendly: true,
    searchTerms: ['web developer', 'frontend developer'],
    projects: [
      'Personal portfolio website',
      'Landing page for a fictional cafe (practice project)',
      'To-do app with JavaScript',
    ],
    interviewQs: [
      'What is the difference between margin and padding?',
      'How do you make a website work well on phones?',
      'Explain what Git is and why teams use it.',
      'Walk me through a project you built and one bug you fixed.',
    ],
    coreModules: [
      Module('Foundations of the web', 'Understand how pages are built and styled.', [
        Lesson('web-1', 'HTML: structure a page', 'freeCodeCamp',
            'https://www.freecodecamp.org/learn',
            'Build a one-page profile with a heading, an image, a list and 3 links.'),
        Lesson('web-2', 'CSS: style and layout', 'MDN Web Docs: CSS first steps',
            'https://developer.mozilla.org/en-US/docs/Learn/CSS/First_steps',
            'Restyle your page with flexbox and make it look good on a phone.'),
        Lesson('web-3', 'JavaScript basics', 'javascript.info', 'https://javascript.info/',
            'Add a button to your page that changes some text and a colour.'),
      ]),
      Module('Ship real work', 'Publish projects the world can see.', [
        Lesson('web-4', 'Git and GitHub', 'Pro Git book', 'https://git-scm.com/book/en/v2',
            'Put your page in a GitHub repository and make 3 commits.'),
        Lesson('web-5', 'Publish your site', 'GitHub Pages', 'https://pages.github.com/',
            'Publish your page and open it on your phone to test it.'),
        Lesson('web-6', 'Build a client-style project', 'The Odin Project',
            'https://www.theodinproject.com/',
            'Build a 3-page site for a fictional local business (label it as a practice project).'),
      ]),
    ],
    quiz: [
      QuizQ('Which language describes the structure of a web page?',
          ['HTML', 'CSS', 'Python', 'SQL'], 0,
          'HTML defines headings, paragraphs, images and links. CSS styles them.'),
      QuizQ('Which CSS feature lays items out in a flexible row or column?',
          ['float', 'flexbox', 'z-index', 'opacity'], 1,
          'Flexbox is designed for flexible one-dimensional layouts.'),
      QuizQ('What does "git commit" do?',
          [
            'Uploads your site to the internet',
            'Saves a snapshot of staged changes to history',
            'Deletes old files',
            'Starts a web server'
          ],
          1,
          'A commit records a snapshot of your staged changes in the project history.'),
      QuizQ('What helps a page adapt to phone screens?',
          [
            'Fixed pixel widths everywhere',
            'Responsive design with flexible layouts',
            'Bigger images only',
            'Removing CSS'
          ],
          1,
          'Responsive design uses flexible layouts and media queries.'),
    ],
  ),
  Career(
    id: 'video',
    title: 'Video Editor & Motion Designer',
    summary: 'Edit videos, reels and ads for creators, brands and agencies.',
    beginnerPath:
        'No degree needed. Free editing software is enough to start. Edit your own footage, build a 45-second showreel and offer short-form edits to small creators and local businesses.',
    firstIncome:
        'Start with short-form edits (reels, shorts) for small creators and local shops, then build up to longer projects once you have a showreel.',
    icon: Icons.movie_creation_rounded,
    skills: [
      'Video editing',
      'Color grading',
      'Motion graphics',
      'Photoshop/Photo editing',
      'Communication',
      'Time management'
    ],
    interests: ['Video & Audio', 'Creative / Visual'],
    beginnerFriendly: true,
    searchTerms: ['video editor'],
    projects: [
      '45-60 second showreel from your own footage',
      'Short reel for a local business (with their permission)',
      'Before and after colour grade breakdown',
    ],
    interviewQs: [
      'Walk me through your editing workflow from raw footage to export.',
      'How do you handle repeated client revision requests?',
      'Which software and shortcuts do you use most?',
      'How do you manage a tight deadline?',
    ],
    coreModules: [
      Module('Editing fundamentals', 'Tell a clear story with cuts, sound and pacing.', [
        Lesson('vid-1', 'Cuts, pacing and story', 'YouTube: editing basics',
            'https://www.youtube.com/results?search_query=video+editing+basics+for+beginners',
            'Edit 60 seconds of your own footage into a clear beginning, middle and end.'),
        Lesson('vid-2', 'Editing in DaVinci Resolve (free)', 'Blackmagic training',
            'https://www.blackmagicdesign.com/products/davinciresolve/training',
            'Recreate a short reel using cuts, trims and transitions.'),
        Lesson('vid-3', 'Audio clean-up and music', 'YouTube: audio clean-up',
            'https://www.youtube.com/results?search_query=video+audio+cleanup+beginners',
            'Balance voice and music so speech is always clear.'),
      ]),
      Module('Polish and sell', 'Make your work look professional and show it.', [
        Lesson('vid-4', 'Colour correction and grading', 'Blackmagic training',
            'https://www.blackmagicdesign.com/products/davinciresolve/training',
            'Match the colour across 3 different clips.'),
        Lesson('vid-5', 'Titles and motion graphics', 'Blackmagic training',
            'https://www.blackmagicdesign.com/products/davinciresolve/training',
            'Animate a simple lower-third title.'),
        Lesson('vid-6', 'Build a showreel and deliver exports', 'YouTube: showreel tips',
            'https://www.youtube.com/results?search_query=how+to+make+a+video+editing+showreel',
            'Create a 45-second showreel using only your own or properly licensed footage.'),
      ]),
    ],
    quiz: [
      QuizQ('What is a J-cut?',
          [
            'Video of the next clip starts before its audio',
            'Audio of the next clip starts before its video',
            'A cut that removes audio',
            'A transition effect'
          ],
          1,
          'In a J-cut the next clip\'s audio begins before its picture.'),
      QuizQ('Which export format is most widely compatible for social platforms?',
          ['H.264 MP4', 'Uncompressed AVI', 'RAW', 'GIF'], 0,
          'H.264 MP4 is supported almost everywhere.'),
      QuizQ('What is the main goal of colour correction?',
          [
            'Add a stylised look',
            'Make colours natural and consistent before stylising',
            'Make video brighter always',
            'Reduce file size'
          ],
          1,
          'Correct first, grade (stylise) second.'),
      QuizQ('Why use proxy files when editing heavy footage?',
          [
            'They improve final export quality',
            'They give smoother playback while editing',
            'They remove noise',
            'They add effects'
          ],
          1,
          'Proxies are lightweight copies that play smoothly; the final export uses the originals.'),
    ],
  ),
  Career(
    id: 'data',
    title: 'Data Analyst',
    summary: 'Turn data into insights using spreadsheets, SQL and charts.',
    beginnerPath:
        'Start with spreadsheets, then SQL, then Python. Analyse free public datasets and publish 3 small reports as your portfolio. A degree helps for some employers but project proof counts a lot for entry-level and freelance work.',
    firstIncome:
        'Offer spreadsheet clean-up, reports and dashboards to small businesses, or apply for junior analyst and data intern roles with 3 portfolio reports.',
    icon: Icons.bar_chart_rounded,
    skills: [
      'Excel/Sheets',
      'SQL',
      'Python',
      'Statistics',
      'Data visualization',
      'Communication'
    ],
    interests: ['Numbers & Data', 'Technology'],
    beginnerFriendly: true,
    searchTerms: ['data analyst'],
    projects: [
      'Analyse a public dataset and write a one-page report',
      'Personal budget dashboard using sample data',
      'Sales analysis on a sample dataset',
    ],
    interviewQs: [
      'How do you handle missing or messy data?',
      'Explain what a JOIN does in SQL.',
      'How would you explain a finding to a non-technical manager?',
      'Tell me about an analysis you did from start to finish.',
    ],
    coreModules: [
      Module('Core tools', 'Work with data in sheets, SQL and Python.', [
        Lesson('dat-1', 'Spreadsheets for analysis', 'Microsoft Excel help',
            'https://support.microsoft.com/excel',
            'Clean a small dataset: remove duplicates, fix formats and build a pivot table.'),
        Lesson('dat-2', 'SQL queries', 'SQLBolt', 'https://sqlbolt.com/',
            'Finish the first 6 SQLBolt lessons and write 5 filtering and sorting queries.'),
        Lesson('dat-3', 'Python basics', 'Kaggle Learn: Python', 'https://www.kaggle.com/learn/python',
            'Write a script that reads a CSV file and prints a summary.'),
      ]),
      Module('Analysis and storytelling', 'Find insights and present them clearly.', [
        Lesson('dat-4', 'Data analysis with pandas', 'Kaggle Learn: pandas',
            'https://www.kaggle.com/learn/pandas',
            'Load a dataset and answer 5 questions about it.'),
        Lesson('dat-5', 'Statistics fundamentals', 'Khan Academy',
            'https://www.khanacademy.org/math/statistics-probability',
            'Explain mean, median and standard deviation using your own dataset.'),
        Lesson('dat-6', 'Visualisation and storytelling', 'Kaggle Learn: data visualization',
            'https://www.kaggle.com/learn/data-visualization',
            'Make 3 charts from a public dataset and write 3 insights.'),
      ]),
    ],
    quiz: [
      QuizQ('Which SQL clause filters rows?', ['SELECT', 'WHERE', 'ORDER BY', 'GROUP'], 1,
          'WHERE keeps only the rows that match a condition.'),
      QuizQ('What is the median?',
          [
            'The average of all values',
            'The most common value',
            'The middle value when sorted',
            'The largest value'
          ],
          2,
          'The median is the middle value of a sorted list.'),
      QuizQ('Best chart for showing change over time?',
          ['Pie chart', 'Line chart', 'Scatter of names', 'Table only'], 1,
          'Line charts show trends over time clearly.'),
      QuizQ('Which is part of cleaning data?',
          [
            'Fixing duplicates and missing values',
            'Adding random values',
            'Deleting the source file',
            'Making charts'
          ],
          0,
          'Cleaning means fixing duplicates, missing values and inconsistent formats.'),
    ],
  ),
  Career(
    id: 'marketing',
    title: 'Digital Marketer',
    summary: 'Help businesses grow with content, search, social media and email.',
    beginnerPath:
        'Free courses and real practice are enough to start. Pick a small local business (with permission), plan their content and write sample copy. Document results in simple case studies.',
    firstIncome:
        'Offer social media content, simple SEO fixes and email copy to small businesses, or apply for social media assistant and marketing intern roles.',
    icon: Icons.campaign_rounded,
    skills: ['SEO', 'Social media', 'Copywriting', 'Email marketing', 'Analytics', 'Communication'],
    interests: ['Business & Sales', 'Writing', 'Creative / Visual'],
    beginnerFriendly: true,
    searchTerms: ['digital marketing'],
    projects: [
      '30-day content plan for a local business (with permission)',
      'SEO check of your own website',
      'A 3-email welcome sequence for a fictional product',
    ],
    interviewQs: [
      'How would you promote a small local business on a tiny budget?',
      'What metrics tell you a campaign is working?',
      'How do you write a headline that gets clicks honestly?',
      'Tell me about a content piece you created and what you learned.',
    ],
    coreModules: [
      Module('Marketing foundations', 'Understand audience, search and social.', [
        Lesson('mkt-1', 'Marketing fundamentals', 'Google Digital Garage',
            'https://learndigital.withgoogle.com/digitalgarage',
            'Describe one local business\'s audience, offer and channels in 10 lines.'),
        Lesson('mkt-2', 'SEO basics', 'Moz: Beginner\'s Guide to SEO',
            'https://moz.com/beginners-guide-to-seo',
            'Choose 5 keywords for a niche and write a title and description for each.'),
        Lesson('mkt-3', 'Social media content', 'HubSpot Academy', 'https://academy.hubspot.com/',
            'Plan a 7-day content calendar for a niche.'),
      ]),
      Module('Grow and measure', 'Email, analytics and writing that converts.', [
        Lesson('mkt-4', 'Email marketing', 'HubSpot Academy', 'https://academy.hubspot.com/',
            'Write a 3-email welcome sequence.'),
        Lesson('mkt-5', 'Analytics', 'Google Skillshop', 'https://skillshop.withgoogle.com/',
            'Read a sample analytics report and note 3 insights.'),
        Lesson('mkt-6', 'Copywriting and a case study', 'HubSpot Academy',
            'https://academy.hubspot.com/',
            'Write landing page copy and a case study for a practice project.'),
      ]),
    ],
    quiz: [
      QuizQ('What does SEO stand for?',
          [
            'Search Engine Optimization',
            'Social Engagement Output',
            'Site Editing Operations',
            'Search Email Outreach'
          ],
          0,
          'SEO means improving a site so search engines can find and rank it.'),
      QuizQ('CTR (click-through rate) is...',
          [
            'Clicks divided by impressions',
            'Revenue divided by cost',
            'Visitors divided by days',
            'Likes divided by followers'
          ],
          0,
          'CTR = clicks / impressions.'),
      QuizQ('A call to action is...',
          [
            'A legal notice',
            'A prompt telling the reader what to do next',
            'A discount',
            'A logo'
          ],
          1,
          'A call to action tells people the next step, such as "Sign up".'),
      QuizQ('Which metric shows visitors who leave after one page?',
          ['Bounce rate', 'Open rate', 'Impressions', 'Reach'], 0,
          'Bounce rate = single-page visits.'),
    ],
  ),
  Career(
    id: 'design',
    title: 'UI/UX & Graphic Designer',
    summary: 'Design apps, websites, posters and brand visuals people enjoy using.',
    beginnerPath:
        'Learn design basics and Figma for free, redesign 2-3 existing screens as practice, and write short case studies. Your portfolio matters more than a degree for most freelance and junior roles.',
    firstIncome:
        'Offer social media graphics, logos or simple app screens to small businesses, or apply for design internships with a 3-project portfolio.',
    icon: Icons.brush_rounded,
    skills: [
      'Figma/UI design',
      'Typography',
      'Photoshop/Photo editing',
      'Research',
      'Problem solving',
      'Communication'
    ],
    interests: ['Design', 'Creative / Visual'],
    beginnerFriendly: true,
    searchTerms: ['ui designer'],
    projects: [
      'Redesign one screen of an app you use (label it as a practice redesign)',
      '5-screen mobile app flow in Figma',
      'Brand kit for a fictional business',
    ],
    interviewQs: [
      'Walk me through your design process on one project.',
      'How do you decide what goes first on a screen?',
      'How do you handle feedback you disagree with?',
      'How do you make a design accessible?',
    ],
    coreModules: [
      Module('Design foundations', 'Learn the rules that make designs work.', [
        Lesson('des-1', 'Design principles', 'Canva Design School',
            'https://www.canva.com/designschool/',
            'Recreate a poster you like using your own wording and images.'),
        Lesson('des-2', 'Typography and colour', 'Google Fonts Knowledge',
            'https://fonts.google.com/knowledge',
            'Pair two fonts and build a colour palette for a fictional brand.'),
        Lesson('des-3', 'Figma basics', 'Figma: learn design',
            'https://www.figma.com/resources/learn-design/',
            'Design a login screen using auto layout.'),
      ]),
      Module('Design for people', 'Test ideas and tell the story.', [
        Lesson('des-4', 'UX research basics', 'Laws of UX', 'https://lawsofux.com/',
            'Ask 3 people to try your screen and note where they get stuck.'),
        Lesson('des-5', 'Design a mobile app flow', 'Material Design 3', 'https://m3.material.io/',
            'Design a 5-screen flow for a small app idea.'),
        Lesson('des-6', 'Write a case study', 'Figma: learn design',
            'https://www.figma.com/resources/learn-design/',
            'Write problem, process, solution and result for one practice project.'),
      ]),
    ],
    quiz: [
      QuizQ('What is visual hierarchy?',
          [
            'Sorting files into folders',
            'Arranging elements so the most important is noticed first',
            'A colour palette',
            'A font family'
          ],
          1,
          'Size, contrast and position guide the eye.'),
      QuizQ('Which helps text accessibility most?',
          [
            'Low-contrast grey on white',
            'Sufficient contrast between text and background',
            'Tiny text',
            'Decorative fonts everywhere'
          ],
          1,
          'Good contrast (for example WCAG 4.5:1 for body text) keeps text readable.'),
      QuizQ('What is a wireframe?',
          ['A final polished design', 'A low-fidelity layout sketch', 'A logo', 'A colour guide'], 1,
          'Wireframes show structure before visual styling.'),
      QuizQ('What does auto layout in Figma do?',
          [
            'Exports code automatically',
            'Lets frames resize and space children automatically',
            'Creates colours',
            'Plays animations'
          ],
          1,
          'Auto layout keeps spacing and resizing consistent.'),
    ],
  ),
  Career(
    id: 'ai',
    title: 'AI & Automation Specialist',
    summary: 'Build no-code automations and AI workflows that save businesses time.',
    beginnerPath:
        'You can begin without coding: learn prompting and a no-code tool like Make or n8n, build 3 working automations for real tasks and document them. Always keep a human approval step before anything is sent to customers.',
    firstIncome:
        'Offer small automations (lead capture, reminders, report generation) to small businesses, or apply for operations and automation assistant roles.',
    icon: Icons.auto_awesome_rounded,
    skills: [
      'Prompt writing/AI tools',
      'No-code automation',
      'Problem solving',
      'Research',
      'Communication',
      'Excel/Sheets'
    ],
    interests: ['Automation & AI', 'Technology', 'Business & Sales'],
    beginnerFriendly: true,
    searchTerms: ['automation'],
    projects: [
      'Form to spreadsheet to email-notification automation',
      'AI-assisted weekly report generator with human approval step',
      'One-page offer describing an automation service',
    ],
    interviewQs: [
      'Describe an automation you built and the time it saved.',
      'How do you make sure an automation does not send wrong information?',
      'How do you write a prompt that gives consistent results?',
      'How would you explain automation to a non-technical business owner?',
    ],
    coreModules: [
      Module('Prompting and automation thinking', 'Learn to instruct AI and map tasks.', [
        Lesson('ai-1', 'Prompting basics', 'Anthropic: prompt engineering overview',
            'https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/overview',
            'Write one prompt with role, task and output format and test 3 versions.'),
        Lesson('ai-2', 'Automation thinking', 'Zapier Learn', 'https://zapier.com/learn',
            'Map one repetitive task as trigger, steps and result.'),
        Lesson('ai-3', 'Build with Make', 'Make Academy', 'https://academy.make.com/',
            'Build a scenario that saves form answers to a spreadsheet.'),
      ]),
      Module('Connect and package', 'Use APIs and turn it into a service.', [
        Lesson('ai-4', 'APIs and webhooks', 'Make Academy', 'https://academy.make.com/',
            'Trigger a scenario using a webhook.'),
        Lesson('ai-5', 'n8n workflows', 'n8n docs', 'https://docs.n8n.io/',
            'Recreate one automation in n8n and compare.'),
        Lesson('ai-6', 'Package your service', 'Zapier Learn', 'https://zapier.com/learn',
            'Write a one-page description of a workflow you can build for a small business.'),
      ]),
    ],
    quiz: [
      QuizQ('What is a webhook?',
          [
            'A type of spreadsheet',
            'An HTTP callback one system sends when an event happens',
            'A password manager',
            'A design tool'
          ],
          1,
          'Webhooks let one app notify another instantly.'),
      QuizQ('What makes a good prompt?',
          [
            'As short as possible',
            'Clear role, context, task and output format',
            'Only keywords',
            'All capital letters'
          ],
          1,
          'Clear instructions and format give more reliable answers.'),
      QuizQ('Why add human approval before an automation sends emails?',
          [
            'To slow things down',
            'To prevent wrong or unwanted messages going out',
            'It is required by law everywhere',
            'To use more credits'
          ],
          1,
          'A quick review catches mistakes before they reach customers.'),
      QuizQ('What is a trigger?',
          [
            'The final step',
            'The event that starts an automation',
            'A bug',
            'A password'
          ],
          1,
          'A trigger is the event, like a new form entry, that starts the workflow.'),
    ],
  ),
  Career(
    id: 'support',
    title: 'Customer Support & Virtual Assistant',
    summary: 'Help customers and busy teams with communication, organisation and admin work.',
    beginnerPath:
        'This is one of the easiest paths to start. Strong communication, reliable organisation and good spreadsheet skills matter more than a degree. Build a small starter pack: sample SOP, email templates and a tidy workspace demo.',
    firstIncome:
        'Apply for customer support and virtual assistant roles, or offer inbox, calendar and spreadsheet help to busy professionals.',
    icon: Icons.support_agent_rounded,
    skills: [
      'Customer support',
      'Communication',
      'Time management',
      'Excel/Sheets',
      'Writing',
      'Research'
    ],
    interests: ['Helping people', 'Business & Sales'],
    beginnerFriendly: true,
    searchTerms: ['customer support'],
    projects: [
      'Sample SOP document for a common task',
      'Set of 5 customer-reply email templates',
      'Organised spreadsheet tracker for a small business (sample data)',
    ],
    interviewQs: [
      'How do you handle an upset customer?',
      'How do you prioritise when everything seems urgent?',
      'Describe a time you organised something that was messy.',
      'How do you keep a client updated on progress?',
    ],
    coreModules: [
      Module('Communication and tools', 'Write clearly and use everyday work tools.', [
        Lesson('sup-1', 'Customer communication', 'HubSpot Academy', 'https://academy.hubspot.com/',
            'Rewrite 3 sample complaints into calm, helpful replies.'),
        Lesson('sup-2', 'Docs and spreadsheets for admin work', 'Google Workspace Learning Center',
            'https://workspace.google.com/learning-center/',
            'Build a simple tracker with filters and a summary row.'),
        Lesson('sup-3', 'Typing and time management', 'Typing.com', 'https://www.typing.com/',
            'Practise typing for 15 minutes a day and plan one week with time blocks.'),
      ]),
      Module('Work like a professional', 'Systems that make you reliable.', [
        Lesson('sup-4', 'Help-desk basics', 'HubSpot Academy', 'https://academy.hubspot.com/',
            'Write rules for how you would sort and answer a support inbox.'),
        Lesson('sup-5', 'Organise work with Notion or Trello', 'Notion guides',
            'https://www.notion.so/help/guides',
            'Set up a task board with owners and due dates for a sample project.'),
        Lesson('sup-6', 'Build a starter pack', 'Your own practice',
            '',
            'Create a sample SOP, 5 email templates and a tracker you can show to clients.'),
      ]),
    ],
    quiz: [
      QuizQ('Best first step with an upset customer?',
          [
            'Argue the facts',
            'Listen and acknowledge the problem',
            'Transfer immediately',
            'Ignore the tone'
          ],
          1,
          'Acknowledging first calms the situation.'),
      QuizQ('SOP stands for...',
          [
            'Standard Operating Procedure',
            'Simple Order Process',
            'System Output Plan',
            'Support Option Program'
          ],
          0,
          'An SOP is a written step-by-step way to do a task.'),
      QuizQ('First response time measures...',
          [
            'How long the whole issue takes',
            'How long until the first reply',
            'Customer age',
            'Inbox size'
          ],
          1,
          'It is the time from request to first reply.'),
      QuizQ('A good client status update includes...',
          [
            'Only good news',
            'What is done, what is next and anything blocked',
            'A long story',
            'Nothing until finished'
          ],
          1,
          'Short, clear updates build trust.'),
    ],
  ),
];

// ---------------------------------------------------------------- Jobs ----

class Job {
  final String id, title, company, type, location, source, description;
  final String? salary, url;
  final bool demo;
  final List<String> tags, requirements;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.location,
    required this.source,
    required this.description,
    this.salary,
    this.url,
    required this.demo,
    required this.tags,
    required this.requirements,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'type': type,
        'location': location,
        'source': source,
        'description': description,
        'salary': salary,
        'url': url,
        'demo': demo,
        'tags': tags,
        'requirements': requirements,
      };

  factory Job.fromJson(Map<String, dynamic> j) => Job(
        id: j['id'].toString(),
        title: (j['title'] ?? '').toString(),
        company: (j['company'] ?? '').toString(),
        type: (j['type'] ?? 'Job').toString(),
        location: (j['location'] ?? '').toString(),
        source: (j['source'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        salary: j['salary']?.toString(),
        url: j['url']?.toString(),
        demo: j['demo'] == true,
        tags: ((j['tags'] ?? []) as List).map((e) => e.toString()).toList(),
        requirements: ((j['requirements'] ?? []) as List).map((e) => e.toString()).toList(),
      );
}

Job _demo(int n, String title, String type, String where, List<String> tags, List<String> reqs) =>
    Job(
      id: 'demo-$n',
      title: title,
      company: 'Sample Company (demo)',
      type: type,
      location: where,
      source: 'Demo data',
      description:
          'This is a sample listing created to show how Skillify works. It is NOT a real job opening and has no application link.',
      demo: true,
      tags: tags,
      requirements: reqs,
    );

/// Clearly labelled sample data. No real companies, no real openings, no salaries.
final List<Job> demoJobs = [
  _demo(1, 'Junior Web Developer', 'Job', 'Remote (sample)',
      ['HTML', 'CSS', 'JavaScript', 'Git'],
      ['Comfortable with HTML, CSS and JavaScript', 'Basic Git workflow', 'A portfolio of small projects']),
  _demo(2, 'Frontend Intern', 'Internship', 'Remote (sample)',
      ['HTML', 'CSS', 'JavaScript'],
      ['Willingness to learn', 'Basic HTML/CSS/JS knowledge']),
  _demo(3, 'Landing Page for a Small Business', 'Freelance', 'Remote (sample)',
      ['HTML', 'CSS', 'Communication'],
      ['Build a one-page responsive site', 'Clear communication with the client']),
  _demo(4, 'Short-form Video Editor', 'Freelance', 'Remote (sample)',
      ['Video editing', 'Motion graphics', 'Communication'],
      ['Edit reels and shorts', 'Add captions and simple motion graphics', 'Meet deadlines']),
  _demo(5, 'Video Editing Apprentice', 'Apprenticeship', 'On-site (sample)',
      ['Video editing', 'Color grading', 'Time management'],
      ['Basic editing software skills', 'Eagerness to learn on the job']),
  _demo(6, 'Junior Data Analyst', 'Job', 'Hybrid (sample)',
      ['Excel/Sheets', 'SQL', 'Data visualization'],
      ['Spreadsheet skills', 'Basic SQL', 'Ability to present simple charts']),
  _demo(7, 'Data Intern', 'Internship', 'Remote (sample)',
      ['Excel/Sheets', 'Python', 'Statistics'],
      ['Basic Python or spreadsheets', 'Curiosity about data']),
  _demo(8, 'Social Media Assistant', 'Job', 'Remote (sample)',
      ['Social media', 'Copywriting', 'Communication'],
      ['Write short engaging posts', 'Understand basic social analytics']),
  _demo(9, 'SEO Content Freelancer', 'Freelance', 'Remote (sample)',
      ['SEO', 'Copywriting', 'Research'],
      ['Keyword research basics', 'Clear writing']),
  _demo(10, 'UI Design Intern', 'Internship', 'Remote (sample)',
      ['Figma/UI design', 'Typography', 'Research'],
      ['Figma basics', 'A small design portfolio']),
  _demo(11, 'Workflow Automation Freelancer', 'Freelance', 'Remote (sample)',
      ['No-code automation', 'Prompt writing/AI tools', 'Problem solving'],
      ['Experience with a no-code automation tool', 'Document the workflows you build']),
  _demo(12, 'Customer Support Associate', 'Job', 'Remote (sample)',
      ['Customer support', 'Communication', 'Time management'],
      ['Clear written communication', 'Patience and reliability']),
  _demo(13, 'Virtual Assistant', 'Freelance', 'Remote (sample)',
      ['Time management', 'Excel/Sheets', 'Communication'],
      ['Organise calendars and inboxes', 'Spreadsheet basics']),
];
