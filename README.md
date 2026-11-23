# SchatzApp Admin Panel

Flutter Web admin panel for SchatzApp. It uses the same Supabase project as the mobile app, with separate admin authentication and permissions.

- Live preview: https://thetechguydev.github.io/schatzapp-Admin/
- Current stage: UI phases (sample data). The backend (Supabase SQL, RLS, Edge Functions) follows after the UI.

## Structure
- `lib/core/modules.dart`: module registry. Add a new section by adding one `AdminModule`; the side nav and routes pick it up.
- `lib/shell/`: responsive shell (full side nav on desktop, icon rail on tablet, slide-out menu on phone).
- `lib/features/<module>/`: one folder per section.
- `lib/widgets/`: shared cards, charts, buttons.
- `design/`: approved UI references.

## Build
```
flutter pub get
flutter build web --release --no-web-resources-cdn --base-href /schatzapp-Admin/
```
Deploys automatically to GitHub Pages on every push to `main` (`.github/workflows/deploy.yml`).
