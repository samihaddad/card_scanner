package dev.samihaddad.card_scanner;

import android.graphics.Point;
import android.graphics.Rect;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.text.Text;
import com.google.mlkit.vision.text.TextRecognition;
import com.google.mlkit.vision.text.TextRecognizer;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** CardScannerPlugin */
public class CardScannerPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "plugins.samihaddad.dev/card_scanner");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.samihaddad.dev/card_scanner");
    channel.setMethodCallHandler(new CardScannerPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    if (call.method.equals("scanCard")) {
      Map<String, Object> imageData = call.arguments();

      byte[] bytes = (byte[]) imageData.get("bytes");
      Map<String, Object> metadataData = (Map<String, Object>) imageData.get("metadata");
      int rotation = (int) imageData.get("rotation");

      InputImage image = InputImage.fromByteArray(
              bytes,
              /* image width */480,
              /* image height */360,
              rotation,
              InputImage.IMAGE_FORMAT_NV21 // or IMAGE_FORMAT_YV12
      );
      TextRecognizer recognizer = TextRecognition.getClient();
      Task<Text> scanResult =
              recognizer.process(image)
                      .addOnSuccessListener(new OnSuccessListener<Text>() {
                        @Override
                        public void onSuccess(Text visionText) {
                          // Task completed successfully
                          // ...
                          String resultText = visionText.getText();
                          for (Text.TextBlock block : visionText.getTextBlocks()) {
                            String blockText = block.getText();
                            Point[] blockCornerPoints = block.getCornerPoints();
                            Rect blockFrame = block.getBoundingBox();
                            for (Text.Line line : block.getLines()) {
                              String lineText = line.getText();
                              Point[] lineCornerPoints = line.getCornerPoints();
                              Rect lineFrame = line.getBoundingBox();
                              for (Text.Element element : line.getElements()) {
                                String elementText = element.getText();
                                Point[] elementCornerPoints = element.getCornerPoints();
                                Rect elementFrame = element.getBoundingBox();
                              }
                            }
                          }
                        }
                      })
                      .addOnFailureListener(
                              new OnFailureListener() {
                                @Override
                                public void onFailure(@NonNull Exception e) {
                                  // Task failed with an exception
                                  // ...
                                }
                              });


      Map<String,String> map = new HashMap<String,String>();
      result.success(map);
    } else {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
