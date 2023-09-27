package io.flutter.plugins.googlemaps.cozy;

import android.content.Context;
import android.view.Display;
import android.annotation.TargetApi;
import android.view.WindowManager;
import android.graphics.Bitmap;
import android.animation.ValueAnimator;
import android.animation.ObjectAnimator;
import android.view.animation.Interpolator;
import androidx.core.view.animation.PathInterpolatorCompat;
import android.util.Log;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.lang.SuppressWarnings;

import java.util.*;
import android.os.*;
import java.util.Map;

import io.flutter.plugins.googlemaps.MarkerBuilder;
import io.flutter.plugins.googlemaps.Convert;
import io.flutter.plugins.googlemaps.MarkerController;

public class CozyMarkerAnimator {
    final float deviceFPS;
    final int markersTransitionAnimationDuration = 400;
    final CozyMarkerBuilder cozyMarkerBuilder;

    public CozyMarkerAnimator(Context context, CozyMarkerBuilder cozyMarkerBuilder){
        this.cozyMarkerBuilder = cozyMarkerBuilder;
        deviceFPS = getDeviceFPS(context);
        Log.d("CozyMarkerAnimator", "deviceFPS: " + deviceFPS);
    }

    private float getDeviceFPS(Context context){
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            return legacyGetDeviceFPS(context);
        }
        return context.getDisplay().getRefreshRate();
    }

    @SuppressWarnings("deprecation")
    private float legacyGetDeviceFPS(Context context){
        Display display = ((WindowManager) context.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay();
        return display.getRefreshRate();
    }

    public void animateMarkerTransition(MarkerController markerController, Object newMarker, CozyMarkerData startMarkerData, CozyMarkerData endMarkerData, GoogleMap googleMap, Map<String, String> googleMapsMarkerIdToDartMarkerId){
        final List<BitmapDescriptor> bitmapsForFrame = new ArrayList<BitmapDescriptor>();
        final Deque<Marker> markersQueue = new ArrayDeque<Marker>();

        // Needed simultaneous markers because when switching frames it could have a gap between the previous and the next frame, causing glitch
        final int totalNumberOfSimultaneousMarkers = 3;
        final int framesNumber = (int) (deviceFPS * ((float) markersTransitionAnimationDuration / 1000));

        for(int i = 1; i <= framesNumber; i++){
            float step = (float) i/framesNumber;
            final BitmapDescriptor markerIconFrame = BitmapDescriptorFactory.fromBitmap(cozyMarkerBuilder.buildAnimatedMarker(startMarkerData, endMarkerData, step));
            bitmapsForFrame.add(markerIconFrame);
        }

        // templateMarkerOptions to be used as template repeatedly on all frames
        MarkerBuilder templateMarkerBuilder = new MarkerBuilder();
        String markerId = Convert.interpretMarkerOptionsWithoutIcon(newMarker, templateMarkerBuilder);
        MarkerOptions templateMarkerOptions = templateMarkerBuilder.build();
        markersQueue.add(markerController.marker);

        // Animation itself    
        final Handler handler = new Handler(Looper.getMainLooper());
        ValueAnimator transitionAnimator = ValueAnimator.ofFloat(0f, 1f);
        transitionAnimator.setDuration(markersTransitionAnimationDuration);
        transitionAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                int animationIndex = (int) ((float) animation.getAnimatedValue() * framesNumber);

                if(animationIndex > 0 && animationIndex <= framesNumber){
                    templateMarkerOptions.icon(bitmapsForFrame.get(animationIndex - 1));
                    Marker newMarker = googleMap.addMarker(templateMarkerOptions);
                    markersQueue.add(newMarker);
                    googleMapsMarkerIdToDartMarkerId.put(newMarker.getId(), markerId);
                }

                if(markersQueue.
                    size() > totalNumberOfSimultaneousMarkers){
                    Marker markerToRemove = markersQueue.remove();
                    googleMapsMarkerIdToDartMarkerId.remove(markerToRemove.getId());
                    markerToRemove.remove();
                }

                // After some time, remove all exceeding markers
                if((float) animation.getAnimatedValue() == 1f){
                    handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        while(markersQueue.size() > 1){
                                Marker markerToRemove = markersQueue.remove();
                                markerToRemove.remove();
                                }
                        markerController.replace(markersQueue.remove());
                        markerController.currentCozyMarkerData = endMarkerData;
                    }
                    }, 100);
                }
            }
        });

        // Ease-out interpolation: https://easings.net/#easeOutCubic
        Interpolator transitionInterpolator = PathInterpolatorCompat.create(0.33f, 1f, 0.68f, 1f);
        transitionAnimator.setInterpolator(transitionInterpolator);
        transitionAnimator.start();
    }
}