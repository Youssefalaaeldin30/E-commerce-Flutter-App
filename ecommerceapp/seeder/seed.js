const fetch = require('node-fetch');
const admin = require('firebase-admin');


const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fetchFakeStore() {
  const res = await fetch('https://fakestoreapi.com/products');
  if (!res.ok) throw new Error('Failed to fetch Fake Store API: ' + res.status);
  return res.json();
}

async function seed() {
  try {
    const products = await fetchFakeStore();
    console.log(`Fetched ${products.length} products from Fake Store`);

    const batchLimit = 400;

    for (let i = 0; i < products.length; i += batchLimit) {
      const batch = db.batch();
      const slice = products.slice(i, i + batchLimit);

      slice.forEach(product => {
        const docRef = db.collection('products').doc(String(product.id));
        const doc = {
          name: product.title,
          price: Number(product.price),
          image: product.image,
          description: product.description,
          category: product.category,
          rating: product.rating || { rate: null, count: null },
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        };
        batch.set(docRef, doc, { merge: true });
      });

      await batch.commit();
      console.log(`Committed batch ${Math.floor(i / batchLimit) + 1}`);
    }

    console.log('Seeding completed — products written to Firestore');
  } catch (err) {
    console.error('Seed failed:', err);
    process.exit(1);
  }
}

seed();
