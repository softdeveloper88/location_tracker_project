package com.example.location_tracker_app

import android.annotation.SuppressLint
import android.app.Activity
import android.app.ActivityManager
import android.app.AlertDialog
import android.content.Context
import android.location.LocationManager
import android.util.Log

object Util {
    fun isBackgroundAppServiceRunning(serviceClass: Class<*>, mActivity: Activity): Boolean {
        val manager: ActivityManager =
            mActivity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
            if (serviceClass.name == service.service.className) {
                Log.i("Service status", "Running")
                return true
            }
        }
        Log.i("Service status", "Not running")
        return false
    }
    fun isLocationEnabledOrNot(context: Context): Boolean {
        var locationManager: LocationManager? = null
        locationManager =
            context.getSystemService(Context.LOCATION_SERVICE) as LocationManager?
        return locationManager!!.isProviderEnabled(LocationManager.GPS_PROVIDER) || locationManager.isProviderEnabled(
            LocationManager.NETWORK_PROVIDER
        )
    }

    @SuppressLint("SuspiciousIndentation")
    fun showAlertLocation(context: Context, title: String, message: String, btnText: String) {
      val alertDialog = AlertDialog.Builder(context).create()
        alertDialog.setTitle(title)
        alertDialog.setMessage(message)
        alertDialog.setButton(btnText) { dialog, which ->
            dialog.dismiss()
        }
        alertDialog.show()
    }

}