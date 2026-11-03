# Container Orchestration (ATS038)

Kubernetes and Cloud Native Associate (KCNA) — Container Orchestration, 28% of the published curriculum. This course is part of ATP008.

Concept lessons explain each official objective through concrete examples, diagrams and scenario reasoning. Every module has a kind-based playground, a graded lab and a summary. Every section begins with an introduction and ends with a capstone lab and a knowledge-check quiz, and a final domain quiz closes the course.

## Course Outline

| Section | Objective | Modules | Status |
| --- | --- | --- | --- |
| 010 | Networking | 3 | Hands-on build; UNTESTED |
| 020 | Security | 2 | Hands-on build; UNTESTED |
| 030 | Troubleshooting | 2 | Hands-on build; UNTESTED |
| 040 | Storage | 2 | Hands-on build; UNTESTED |

See [the curriculum map](CURRICULUM.md) for module outcomes. The manifest registers readings in teaching order.

## Authoring Status

Labs, playgrounds, capstones and quizzes are now in scope (the earlier reading-only rule was lifted on 2026-11-03). Every playground and lab targets `kindest/node:v1.35.8` and is statically checked only (`astrona validate`, `bash -n`, YAML parse): none has been run end to end, and each lab README says UNTESTED. Quizzes are `sections/section-0N0/quiz.yaml` and `sections/final-domain-quiz.yaml`. The older `questions.yaml` banks and `assessments/` folder from the reading-only draft are kept but unused by the manifest. Technical sections and the ATP008 registration remain draft until the maintainer approves publication.

## Sources And Contributions

Author references are recorded in [SOURCES.md](SOURCES.md). Report corrections through this repository’s issues. The material uses the repository license.
