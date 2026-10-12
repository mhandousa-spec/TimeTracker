#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

// File Name: flutter_window.cpp
// Updated: 26/8/2026 - handles the `screen_capture` channel behind the
//          Settings > Take Screen Shot switch.
//
// Windows lever: SetWindowDisplayAffinity. WDA_EXCLUDEFROMCAPTURE (Windows 10
// version 2004 / build 19041 and newer) leaves the window out of every capture
// path entirely — screenshots, Snipping Tool, Teams/Zoom shares and recorders
// all see the desktop behind it, while the window stays fully visible on the
// physical screen. On older builds the call fails and we fall back to
// WDA_MONITOR, which is cruder: the capture gets a black rectangle.
namespace {

// Defined in newer Windows SDK headers; declared here so the runner builds
// against an older SDK too.
#ifndef WDA_NONE
constexpr DWORD WDA_NONE = 0x00000000;
#endif
#ifndef WDA_MONITOR
constexpr DWORD WDA_MONITOR = 0x00000001;
#endif
#ifndef WDA_EXCLUDEFROMCAPTURE
constexpr DWORD WDA_EXCLUDEFROMCAPTURE = 0x00000011;
#endif

constexpr char kScreenCaptureChannel[] = "knowticed_plus/screen_capture";

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  SetUpScreenCaptureChannel();

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  screen_capture_channel_ = nullptr;

  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::SetUpScreenCaptureChannel() {
  screen_capture_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(), kScreenCaptureChannel,
          &flutter::StandardMethodCodec::GetInstance());

  screen_capture_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() != "setAllowed") {
          result->NotImplemented();
          return;
        }

        bool allowed = true;
        if (const auto* arguments =
                std::get_if<flutter::EncodableMap>(call.arguments())) {
          const auto entry =
              arguments->find(flutter::EncodableValue("allowed"));
          if (entry != arguments->end()) {
            if (const bool* value = std::get_if<bool>(&entry->second)) {
              allowed = *value;
            }
          }
        }

        result->Success(
            flutter::EncodableValue(ApplyScreenCapturePolicy(allowed)));
      });
}

bool FlutterWindow::ApplyScreenCapturePolicy(bool allowed) {
  HWND handle = GetHandle();
  if (!handle) {
    return false;
  }

  if (allowed) {
    ::SetWindowDisplayAffinity(handle, WDA_NONE);
    return false;
  }

  // Preferred: the window is skipped by capture entirely.
  if (::SetWindowDisplayAffinity(handle, WDA_EXCLUDEFROMCAPTURE)) {
    return true;
  }

  // Pre-2004 Windows 10: the capture gets a black rectangle instead.
  return ::SetWindowDisplayAffinity(handle, WDA_MONITOR) != FALSE;
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
