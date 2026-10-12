#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // Sets up the "knowticed_plus/screen_capture" channel behind the
  // Settings > Take Screen Shot switch.
  void SetUpScreenCaptureChannel();

  // Applies (or lifts) the capture block on this window.
  // |allowed| true = screenshots permitted, false = blocked.
  // Returns whether the block is in effect afterwards.
  bool ApplyScreenCapturePolicy(bool allowed);

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // Channel behind the Take Screen Shot setting.
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      screen_capture_channel_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
