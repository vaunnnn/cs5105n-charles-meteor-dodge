# README documentation instructions

## Purpose

`README.md` is the cumulative project record for Meteor Dodge, covering **Week 1
through Week 8**. Build on the existing documentation as the project develops.
Each new week adds to the record; it does not replace earlier weeks.

Read this guide before editing `README.md`.

## Preserve existing work

- Keep earlier weekly sections, descriptions, screenshots, captions, and asset
  credits. Do not rewrite the entire README to document the latest week.
- Do not remove or condense earlier weeks into a short summary or links section.
- Keep screenshots embedded with `![Descriptive caption](screenshots/file.png)`
  or their existing HTML image tags so they display directly on GitHub. Do not
  replace embedded images with ordinary text links.
- Keep older screenshots even when the game's appearance changes. Label them
  with the week they document, and use distinct filenames for newer captures.
- Preserve existing image URLs. If a local image must move, update its references
  and verify that the image remains available.
- Make small corrections when needed, but preserve historical context. Describe
  changed behavior in the new week's section rather than making earlier weeks
  appear to have included later features.
- Ask for explicit direction before deleting historical documentation or doing
  a substantial reorganization.

## Add documentation week by week

Use chronological sections named `## Week 1 - ...` through `## Week 8 - ...`.
Add the next week's section after the last documented week. Update an existing
week's section when adding more work from that same week; avoid duplicate sections.

Keep the project introduction and any shared run instructions or controls useful
to a new reader. Update shared instructions narrowly when behavior changes, and
document that change in the relevant week as well.

For each week, include the applicable details:

- The week's objective and work actually completed.
- Features, mechanics, design decisions, and changes from the previous week.
- Relevant controls or instructions for trying the new work.
- Embedded screenshots with clear captions showing that week's progress.
- Testing performed, results, known issues, and unfinished requirements.
- Asset sources, credits, and AI generation or editing details when applicable.
- Real playtest feedback and the resulting changes, when available.

Do not invent completed work, test results, playtest feedback, asset provenance,
or screenshots. Clearly label planned work and missing evidence as pending.
Do not mark future weeks complete in advance.

## Suggested weekly section

Use only the subsections that apply; this template does not require empty headings.

```markdown
## Week N - Weekly topic

### Objective
Describe the focus of this week.

### Work completed
- Describe the implemented features and changes.

### Screenshots
![Week N: description of the visible feature](screenshots/week-n-feature.png)

Explain what the screenshot demonstrates.

### Testing and feedback
Record checks actually performed and real feedback received.

### Known issues and next steps
Record remaining work without claiming it is complete.

### Assets and credits
Document applicable sources, tools, prompts, and edits.
```

The image path above is an example. Replace it with an existing capture before
adding it to the README.

## Check before finishing a README update

1. Review the diff: earlier documentation and image embeds should remain intact.
2. Confirm the new material belongs to the correct week and keeps Weeks 1–8 in
   chronological order.
3. Verify local image and document paths resolve, including filename casing for
   GitHub. Check the rendered Markdown when a preview is available.
4. Confirm screenshots remain embedded and captions distinguish historical work
   from the current game.
5. Keep detailed supporting reports in their own files when useful, linking them
   from the relevant week without replacing its documentation.

## Existing README recovery

The Week 5 commit `3dfef7b` replaced much of the earlier weekly structure and
changed screenshot embeds into plain links. Earlier documentation is available
in the README history before that commit (`3dfef7b^:README.md`).

When restoring that history, merge the earlier weekly content and image embeds
with the existing Week 5 documentation. Preserve both sets of work rather than
replacing the current README wholesale with an older version.

The README now merges the earlier weekly content and embedded screenshots with
the Week 5 documentation. Preserve this cumulative structure in future updates.
