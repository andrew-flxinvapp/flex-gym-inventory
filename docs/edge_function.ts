import { withSupabase } from 'npm:@supabase/server@^1'

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const SUPPORT_NOTIFICATION_EMAIL = Deno.env.get(
  'SUPPORT_NOTIFICATION_EMAIL',
)
const SUPPORT_FROM_EMAIL = Deno.env.get('SUPPORT_FROM_EMAIL')

const allowedCategories = [
  'bug_report',
  'account',
  'equipment',
  'gyms',
  'wishlist',
  'export',
  'subscriptions',
  'feature_request',
  'general_question',
  'other',
]

type SupportRequestBody = {
  category: string
  subject: string
  message: string
  app_version?: string | null
  build_number?: string | null
  platform?: string | null
  device_model?: string | null
  os_version?: string | null
}

function escapeHtml(value: string) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;')
}

export default {
  fetch: withSupabase(
    { auth: 'user' },

    async (req, ctx) => {
      try {
        const body = (await req.json()) as SupportRequestBody

        const {
          category,
          subject,
          message,
          app_version,
          build_number,
          platform,
          device_model,
          os_version,
        } = body

        const trimmedSubject = subject?.trim()
        const trimmedMessage = message?.trim()

        // Validate required fields
        if (!category || !trimmedSubject || !trimmedMessage) {
          return Response.json(
            {
              success: false,
              error: 'Missing required fields.',
            },
            { status: 400 },
          )
        }

        // Validate category
        if (!allowedCategories.includes(category)) {
          return Response.json(
            {
              success: false,
              error: 'Invalid support category.',
            },
            { status: 400 },
          )
        }

        const userId = ctx.userClaims?.sub
        const userEmail = ctx.userClaims?.email

        if (!userId || !userEmail) {
          return Response.json(
            {
              success: false,
              error: 'Unable to identify authenticated user.',
            },
            { status: 401 },
          )
        }

        // Insert support request
        const { data: supportRequest, error: insertError } =
          await ctx.supabaseAdmin
            .from('support_requests')
            .insert({
              user_id: userId,
              user_email: userEmail,

              category,
              subject: trimmedSubject,
              message: trimmedMessage,

              app_version: app_version ?? null,
              build_number: build_number ?? null,
              platform: platform ?? null,
              device_model: device_model ?? null,
              os_version: os_version ?? null,

              status: 'open',
            })
            .select('id')
            .single()

        if (insertError) {
          console.error(
            'Support request insert failed:',
            insertError,
          )

          return Response.json(
            {
              success: false,
              error: 'Unable to save support request.',
            },
            { status: 500 },
          )
        }

        // Support request is already safely stored at this point.
        // If email configuration or delivery fails, do not fail/delete it.

        if (
          !RESEND_API_KEY ||
          !SUPPORT_NOTIFICATION_EMAIL ||
          !SUPPORT_FROM_EMAIL
        ) {
          console.error(
            'Support email configuration is missing.',
          )

          return Response.json({
            success: true,
            request_id: supportRequest.id,
            notification_sent: false,
          })
        }

        // Escape values before inserting them into HTML
        const safeCategory = escapeHtml(category)
        const safeSubject = escapeHtml(trimmedSubject)
        const safeMessage = escapeHtml(trimmedMessage)
        const safeUserEmail = escapeHtml(userEmail)
        const safeUserId = escapeHtml(userId)

        const safeAppVersion = escapeHtml(
          app_version ?? 'Unknown',
        )
        const safeBuildNumber = escapeHtml(
          build_number ?? 'Unknown',
        )
        const safePlatform = escapeHtml(
          platform ?? 'Unknown',
        )
        const safeDeviceModel = escapeHtml(
          device_model ?? 'Unknown',
        )
        const safeOsVersion = escapeHtml(
          os_version ?? 'Unknown',
        )

        // Send notification through Resend
        const resendResponse = await fetch(
          'https://api.resend.com/emails',
          {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${RESEND_API_KEY}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              from: SUPPORT_FROM_EMAIL,
              to: SUPPORT_NOTIFICATION_EMAIL,
              subject: `[FGI Support] ${trimmedSubject}`,
              html: `
                <h2>New Flex Gym Inventory Support Request</h2>

                <p>
                  <strong>Category:</strong>
                  ${safeCategory}
                </p>

                <p>
                  <strong>Subject:</strong><br>
                  ${safeSubject}
                </p>

                <p>
                  <strong>Message:</strong><br>
                  ${safeMessage.replaceAll('\n', '<br>')}
                </p>

                <hr>

                <p>
                  <strong>User Email:</strong>
                  ${safeUserEmail}
                </p>

                <p>
                  <strong>User ID:</strong>
                  ${safeUserId}
                </p>

                <hr>

                <p>
                  <strong>App Version:</strong>
                  ${safeAppVersion}
                </p>

                <p>
                  <strong>Build Number:</strong>
                  ${safeBuildNumber}
                </p>

                <p>
                  <strong>Platform:</strong>
                  ${safePlatform}
                </p>

                <p>
                  <strong>Device:</strong>
                  ${safeDeviceModel}
                </p>

                <p>
                  <strong>OS Version:</strong>
                  ${safeOsVersion}
                </p>

                <hr>

                <p>
                  <strong>Support Request ID:</strong>
                  ${supportRequest.id}
                </p>
              `,
            }),
          },
        )

        if (!resendResponse.ok) {
          const resendError = await resendResponse.text()

          console.error(
            'Resend notification failed:',
            resendError,
          )

          return Response.json({
            success: true,
            request_id: supportRequest.id,
            notification_sent: false,
          })
        }

        // Email succeeded, record timestamp
        const { error: updateError } =
          await ctx.supabaseAdmin
            .from('support_requests')
            .update({
              email_sent_at: new Date().toISOString(),
            })
            .eq('id', supportRequest.id)

        if (updateError) {
          console.error(
            'Unable to update email_sent_at:',
            updateError,
          )
        }

        return Response.json({
          success: true,
          request_id: supportRequest.id,
          notification_sent: true,
        })
      } catch (error) {
        console.error(
          'Unexpected support function error:',
          error,
        )

        return Response.json(
          {
            success: false,
            error: 'Unexpected server error.',
          },
          { status: 500 },
        )
      }
    },
  ),
}