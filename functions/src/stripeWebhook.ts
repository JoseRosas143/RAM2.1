import { onRequest } from "firebase-functions/v2/https";
import Stripe from "stripe";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

initializeApp();
const db = getFirestore();

export const stripeWebhook = onRequest({ cors: true }, async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const secret = process.env.STRIPE_WEBhook_SECRET || process.env.STRIPE_WEBHOOK_SECRET;
  if (!sig || !secret) {
    res.status(400).send('Webhook not configured');
    return;
  }
  try {
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY as string, { apiVersion: "2024-06-20" });
    const event = stripe.webhooks.constructEvent(req.rawBody, sig as string, secret as string);

    switch (event.type) {
      case 'checkout.session.completed':
        // TODO: mark user as premium
        break;
      case 'invoice.payment_succeeded':
        // TODO: upsert subscription status
        break;
      case 'customer.subscription.deleted':
        // TODO: downgrade user
        break;
      default:
        break;
    }

    res.json({ received: true });
  } catch (err: any) {
    console.error(err);
    res.status(400).send(`Webhook Error: ${err.message}`);
  }
});
