Input crash demo

This app crashes in iOS 17. 
It does not crash in iOS 16.6 or lower.

To reproduce: 

Run the app from Xcode 15 onto a iOS 17 iPad.

Then:
1. Turn on the assesment lock (you should see "assessmentSessionDidBegin" in the Xcode output window).
2. Type in the fields.
3. Touch the "Touch to remove focus" button
4. Wait a few seconds (>3?).
5. Touch a text field randomly.
Repeat steps 2-5. Eventually, touching a text field should crash the app.

The message received is "Message from debugger: Terminated due to signal 9"

If it does not reproduce, make sure to turn off assessment mode using the 
toggle before stopping the app. (You should see "assessmentSessionDidEnd" in the Xcode output window)


IMPORTANT!! After crashing/before re-testing, do the following to avoid having to 
restart your iPad to escape assessment mode:

a. Re-run the app from Xcode.
b. Turn on assessment mode (wait for it to start).
c. Turn off assessment mode.
d. Exit the app.
e. Remove/uninstall the app.
