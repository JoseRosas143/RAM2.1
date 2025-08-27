import { onRequest } from "firebase-functions/v2/https";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import Stripe from "stripe";

initializeApp();
const db = getFirestore();

export const api = onRequest({ cors: true }, async (req, res) => {
  const action = (req.query.action || req.body?.action || "").toString();

  if (action === "ping") {
    res.json({ ok: true, t: Date.now() });
    return;
  }

  res.status(404).json({ error: "Unknown action" });
});

export const createCheckoutSession = onRequest({ cors: true }, async (req, res) => {
  try {
    const priceId = (req.body?.priceId || req.query.priceId) as string;
    const successUrl = (req.body?.successUrl || req.query.successUrl) as string;
    const cancelUrl = (req.body?.cancelUrl || req.query.cancelUrl) as string;
    if (!priceId || !successUrl || !cancelUrl) {
      res.status(400).json({ error: "Missing params" });
      return;
    }
    const stripeSecret = process.env.STRIPE_SECRET_KEY;
    if (!stripeSecret) {
      res.status(500).json({ error: "Stripe not configured" });
      return;
    }
    const stripe = new Stripe(stripeSecret, { apiVersion: "2024-06-20" });
    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,
      automatic_tax: { enabled: false }
    });
    res.json({ url: session.url });
  } catch (e: any) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});
