package payment.sdk.android.payments

import android.content.Context
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContract

internal class PaymentsLauncherContract :
    ActivityResultContract<PaymentsRequest, PaymentsResult>() {
    override fun createIntent(context: Context, input: PaymentsRequest): Intent {
        return input.toIntent(context)
    }

    override fun parseResult(resultCode: Int, intent: Intent?): PaymentsResult {
        return intent?.getParcelableExtra(EXTRA_RESULT) ?: PaymentsResult.Failed(
            "Error while processing result."
        )
    }

    internal companion object {
        internal const val EXTRA_RESULT = "card_payments_extra_result"
    }
}