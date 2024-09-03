package com.example.test_project

import android.Manifest
import android.annotation.SuppressLint
import android.app.*
import android.app.admin.DevicePolicyManager
import android.content.*
import android.content.pm.PackageManager
import android.os.*
import android.os.Build.VERSION_CODES
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.location_tracker_app.Util
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.*
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.tasks.OnFailureListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    val RESULT_ENABLE = 1
    var deviceManger: DevicePolicyManager? = null
    var activityManager: ActivityManager? = null
    lateinit var mServiceIntent: Intent
    lateinit var mActivity: Activity
    var sensorScreen = false
    private val CHANNEL = "flutter.native/helper"
    lateinit var editor: SharedPreferences.Editor
    val PERMISSIONS_REQUEST_LOCATION = 99

    @SuppressLint("HardwareIds")
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // TODO: Register ListTileNativeAdFactory
        deviceManger = getSystemService(
            Context.DEVICE_POLICY_SERVICE
        ) as DevicePolicyManager
        activityManager = getSystemService(
            Context.ACTIVITY_SERVICE
        ) as ActivityManager
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler {
                // Note: this method is invoked on the main thread.
                    call, result ->
                when (call.method) {


                    "locationPermission" -> {
//                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                            requestDeviceLocationPermission()
//                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

                            requestDeviceLocationPermission()

                        } else {

                            if (ActivityCompat.checkSelfPermission(
                                    (context as MainActivity),
                                    Manifest.permission.ACCESS_COARSE_LOCATION
                                ) !=
                                PackageManager.PERMISSION_GRANTED
                            ) {
                                requestDeviceLocationPermission()

                            }
                        }

                    }
                    "PhoneDeviceId" -> {
                        val deviceId = Settings.Secure.getString(
                            application.contentResolver,
                            Settings.Secure.ANDROID_ID
                        )
                        result.success(deviceId)
                    }

                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        try {
            when (requestCode) {

                1001 -> {
                    if (Build.VERSION.SDK_INT >= VERSION_CODES.M) {
                        if (ActivityCompat.checkSelfPermission(
                                context,
                                Manifest.permission.ACCESS_FINE_LOCATION
                            ) == PackageManager.PERMISSION_GRANTED ||
                            ActivityCompat.checkSelfPermission(
                                context,
                                Manifest.permission.ACCESS_COARSE_LOCATION
                            ) == PackageManager.PERMISSION_GRANTED
                            || ActivityCompat.checkSelfPermission(
                                context,
                                Manifest.permission.ACCESS_BACKGROUND_LOCATION
                            ) == PackageManager.PERMISSION_GRANTED
                        ) {

                        }
                    }
                }
            }
            super.onActivityResult(requestCode, resultCode, data)
        } catch (e: java.lang.RuntimeException) {

        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        // TODO: Unregister the ListTileNativeAdFactory
    }

    @SuppressLint("CommitPrefEdits")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        FlutterMain.startInitialization(this)
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1)
                }
            }
//            if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
//                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), 1001)
//            } else {
//                requestDeviceLocationPermission()
//            }

            editor = getSharedPreferences("com.example.test_project", MODE_PRIVATE).edit()
//            mLocationService = GetLocationService()
//            mServiceIntent = Intent(context, mLocationService.javaClass)
//            mLocationService = GetLocationService()
//            mActivity = this@MainActivity
//        requestLocationPermission()
//        checkRunTimePermission()
            if (!Util.isLocationEnabledOrNot(this)) {
                dialogGpsLocationEnable()
            }
//            mLocationService = GetLocationService()
//            mServiceIntent = Intent(this, mLocationService.javaClass)
//            if (!Util.isBackgroundAppServiceRunning(mLocationService.javaClass, mActivity)) {
//                if (Build.VERSION.SDK_INT >= VERSION_CODES.O) {
//                    ContextCompat.startForegroundService(this, mServiceIntent)
//                }else {
//                    startService(mServiceIntent)
//                }

            //            Toast.makeText(
//                mActivity,
//                getString(R.string.service_start_successfully),
//                Toast.LENGTH_SHORT
//            ).show()
//            } else {
//            Toast.makeText(
//                mActivity,
//                getString(R.string.service_already_running),
//                Toast.LENGTH_SHORT
//            ).show()
//            }
        }catch (e:java.lang.RuntimeException){
            e.printStackTrace()
        }


//        if (Build.VERSION.SDK_INT >= VERSION_CODES.O) {
//            // Create channel to show notifications.
//            val channelId = getString(R.string.default_notification_channel_id)
//            val channelName = getString(R.string.default_notification_channel_name)
//            val notificationManager = getSystemService(NotificationManager::class.java)
//            notificationManager?.createNotificationChannel(
//                NotificationChannel(
//                    channelId,
//                    channelName, NotificationManager.IMPORTANCE_HIGH
//                )
//            )
//        }

        intent.extras?.let {
            for (key in it.keySet()) {
                val value = intent.extras?.get(key)
                Log.d("TAG", "Key: $key Value: $value")
            }
        }

    }

    @RequiresApi(VERSION_CODES.M)
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        when (requestCode) {
            PERMISSIONS_REQUEST_LOCATION -> {
                // If request is cancelled, the result arrays are empty.

                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, yay! Do the
                    // location-related task you need to do.
                    if (ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.ACCESS_FINE_LOCATION
                        ) == PackageManager.PERMISSION_GRANTED
                    ) {


                    }

                } else {
                    if (grantResults.isNotEmpty()) {
                        if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                            //Do the stuff that requires permission...
                        } else if (grantResults[0] == PackageManager.PERMISSION_DENIED) {
                            // Should we show an explanation?
                            requestPermissions(
                                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                                PERMISSIONS_REQUEST_LOCATION
                            )
                            requestPermissions(
                                arrayOf(Manifest.permission.FOREGROUND_SERVICE_LOCATION),
                                PERMISSIONS_REQUEST_LOCATION
                            )
//                            if (ActivityCompat.shouldShowRequestPermissionRationale(
//                                    this,
//                                    Manifest.permission.ACCESS_FINE_LOCATION
//                                )
//                            ) {
//                                //Show permission explanation dialog...
//                            } else {
//                                //Never ask again selected, or device policy prohibits the app from having that permission.
//                                //So, disable that feature, or fall back to another situation...
//                            }
                        }
                    }
                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
//                    Toast.makeText(this, "permission denied", Toast.LENGTH_LONG).show()
                }
                return
            }
        }
    }

    @SuppressLint("MissingPermission")
    override fun onPause() {
        super.onPause()

    }


    private fun dialogGpsLocationEnable() {

        val requestLocation = LocationRequest.create()
        requestLocation.interval = 10000
        requestLocation.fastestInterval = 5000
        requestLocation.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        val mBuilder = LocationSettingsRequest.Builder().addLocationRequest(requestLocation)
        val settingsClient = LocationServices.getSettingsClient(context)
        val task: com.google.android.gms.tasks.Task<LocationSettingsResponse>? =
            settingsClient.checkLocationSettings(mBuilder.build())
        task!!.addOnSuccessListener(
            activity
        ) {

        }
        task.addOnFailureListener(activity, OnFailureListener { e ->
            if (e is ResolvableApiException) {
                val resolvable: ResolvableApiException = e
                try {
                    resolvable.startResolutionForResult(activity, 51)
                } catch (e1: IntentSender.SendIntentException) {
                    e1.printStackTrace()
                }
            }
        })
    }



    private fun requestDeviceLocationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.FOREGROUND_SERVICE_LOCATION,
                    Manifest.permission.ACCESS_BACKGROUND_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION

                ),
                PERMISSIONS_REQUEST_LOCATION
            )
        } else {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                PERMISSIONS_REQUEST_LOCATION
            )
        }
    }

}

