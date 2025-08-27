import { onRequest } from "firebase-functions/v2/https";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

initializeApp();

export const publicProfile = onRequest({ cors: true }, async (req, res) => {
  try {
    // tagId viene de la ruta /p/<tagId> según el rewrite en firebase.json
    const segments = req.path.split("/").filter(Boolean);
    const tagId = segments.length ? segments[segments.length - 1] : (req.query["tagId"] as string);

    if (!tagId) {
      res.status(400).send("Missing tagId");
      return;
    }

    const db = getFirestore();
    const tagRef = db.collection("tags").doc(tagId);
    const tagSnap = await tagRef.get();
    if (!tagSnap.exists) {
      res.status(404).send("Tag not found");
      return;
    }
    const tag = tagSnap.data()!;
    const petRef = db.collection("pets").doc(tag.petId);
    const petSnap = await petRef.get();
    if (!petSnap.exists) {
      res.status(404).send("Pet not found");
      return;
    }
    const pet = petSnap.data()!;
    // Muestra perfil mínimo + botón WhatsApp
    const phone = pet.ownerPhone ?? ""; // opcional
    const wa = phone ? `https://wa.me/${phone}?text=Hola%20tengo%20informaci%C3%B3n%20sobre%20tu%20mascota` : "#";
    const name = pet.name ?? "Mascota";
    const photo = pet.photoUrl ?? "";

    res.setHeader("Content-Type", "text/html; charset=utf-8");
    res.send(`
<!doctype html>
<html><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${name} — Perfil</title>
<style>
body{font-family: system-ui, -apple-system, Segoe UI, Roboto, Ubuntu, Cantarell, Noto Sans, sans-serif; padding:24px; line-height:1.4;}
.card{max-width:560px;margin:auto;padding:24px;border-radius:16px;box-shadow:0 10px 25px rgba(0,0,0,.08);}
img{width:120px;height:120px;object-fit:cover;border-radius:16px;}
.btn{display:inline-block;padding:12px 16px;border-radius:10px;background:#25D366;color:#fff;text-decoration:none;font-weight:600}
.small{color:#666;font-size:14px}
</style></head>
<body>
<div class="card">
  <h2>${name}</h2>
  ${photo ? `<img src="${photo}" alt="${name}">` : ""}
  <p class="small">Si tienes información sobre esta mascota, por favor contacta a su tutor.</p>
  <p><a class="btn" href="${wa}">Enviar mensaje por WhatsApp</a></p>
</div>
</body></html>
    `);
  } catch (e) {
    console.error(e);
    res.status(500).send("Internal error");
  }
});
