importScripts(
  "https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js"
);

firebase.initializeApp({
  apiKey: "AIzaSyAJ3EwNw_WXwmuB5PgEj6JCh8JxXWvBkoE",
  authDomain: "icupa-396da.firebaseapp.com",
  projectId: "icupa-396da",
  storageBucket: "icupa-396da.appspot.com",
  messagingSenderId: "49459051581",
  appId: "1:49459051581:web:86da4bea01e16cd4107e54",
  measurementId: "G-D80RPNQVCZ",
});

const messaging = firebase.messaging();
