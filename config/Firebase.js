import { initializeApp } from "firebase/app";
// import { getAnalytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyDwfO40N-m84M_BJk9pHS1MM3L_CaPKCcs",
  authDomain: "geoattendence-41967.firebaseapp.com",
  projectId: "geoattendence-41967",
  storageBucket: "geoattendence-41967.appspot.com",
  messagingSenderId: "831043633495",
  appId: "1:831043633495:web:a04970cfcdaeb8f5e9be12",
  measurementId: "G-ZPLRK6BZTR",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
// const analytics = getAnalytics(app);
const db = getFirestore(app);
export { app, db };
