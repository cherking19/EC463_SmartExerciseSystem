import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {firestore} from "firebase-admin";

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();


exports.addWorkout = functions.https.onCall(async (data, context) => {
  functions.logger.info("This Works");
  const user = context.auth?.uid;
  const workout = data.workout;
  await db.collection("workouts").doc(user!).set(
      {Workouts: firestore.FieldValue.arrayUnion(workout)},
      {merge: true}
  );
  return "Received "+ user + " " +workout;
  // await db.collection("/workouts").doc(user).create(workout);
});

exports.getWorkouts = functions.https.onCall(async (data, context) => {
  const user = context.auth?.uid;
  return await db.collection("/workouts").doc(user!).get();
});
