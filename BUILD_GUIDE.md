# How to Build & Release Halaqi

## Why the build command changed

Previously the app loaded secrets from a `.env` file bundled **inside** the APK.  
Google's security scanner flagged this as a policy violation.

Now secrets are passed at **build time** using `--dart-define` flags.  
They get compiled into the binary — not stored as readable files inside the APK.

---

## Build Command (Release)

```powershell
flutter build appbundle `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your_publishable_anon_key
```

Or on a single line:

``` powershell
flutter build appbundle --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_publishable_anon_key
```

## Run Locally (Debug)

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://your-project.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your_publishable_anon_key
```

Tip: Prefer environment variables when running tasks.

PowerShell example:

```powershell
$env:SUPABASE_URL="https://your-project.supabase.co"
$env:SUPABASE_ANON_KEY="your_publishable_anon_key"
```

---

## Supabase Edge Function Needed

The delete-account feature calls a Supabase Edge Function called `delete-account`.
You need to create this function in your Supabase dashboard.

Go to: **Supabase Dashboard → Edge Functions → New Function** → name it `delete-account`

Paste this code:

```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  )

  const authHeader = req.headers.get('Authorization')!
  const token = authHeader.replace('Bearer ', '')

  const { data: { user }, error: userError } = await supabaseAdmin.auth.getUser(token)
  if (userError || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
  }

  // Delete user's bookings (adjust table name to match yours)
  await supabaseAdmin.from('bookings').delete().eq('user_id', user.id)

  // Delete the auth user
  const { error } = await supabaseAdmin.auth.admin.deleteUser(user.id)
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }

  return new Response(JSON.stringify({ message: 'Account deleted successfully' }), { status: 200 })
})
```

---

## Google Play Console — Data Safety Checklist

In Play Console → App content → Data safety, declare:

| Data type | Collected | Shared | Purpose |
|-----------|-----------|--------|---------|

| Name | ✅ | No | App functionality |
| Email address | ✅ | No | Account management |
| Phone number | ✅ | No | App functionality |
| Precise location | ✅ | No | App functionality (find nearby shops) |
| Approximate location | ✅ | No | App functionality |

## Google Play Console — Account Deletion Link

In Play Console → App content → Data safety → Account deletion:

- Set the web URL to: `https://www.halaqi.com/privacy-policy` (or create a dedicated deletion page)
- The in-app deletion via the Profile screen button satisfies the in-app requirement ✅
