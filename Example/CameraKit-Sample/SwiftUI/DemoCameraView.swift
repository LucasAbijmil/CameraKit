//
//  CameraDemoView.swift
//  AppPlayground
//
//  Created by Michel-André Chirita on 26/08/2024.
//

import SwiftUI
import CameraKit

struct DemoCameraView: View {
    
    @State var viewModel = DemoCameraViewModel()
    @State private var isAnimated = false

    var body: some View {
        NavigationStack {
            VStack {
              Circle()
                .fill(.red)
                .frame(width: 50)
                .scaleEffect(isAnimated ? 0.8 : 1)
                cameraPreviewView
                buttonsView
                if let _ = viewModel.errorMessage {
                    errorView
                }
            }
            .padding(.horizontal, 10)
            .navigationDestination(isPresented: $viewModel.presentPreview) {
                if let videoUrl = viewModel.videoUrl {
                    DemoPreviewView(url: videoUrl)
                } else {
                    Rectangle().fill(.red)
                }
            }
        }
    }
    
    @ViewBuilder
    private var cameraPreviewView: some View {
        Circle()
            .fill(.clear)
            .stroke(.black, lineWidth: 3)
            .overlay {
                CameraPickerView(
                    cameraSessionDelegate: viewModel,
                    captureMode: .video(resolution: .custom(width: 480, height: 480), frameRate: 60),
                    cameraDirection: .front,
                    isMicEnabled: false,
                    videoFilter: .removeBackground
                ) { controller in
                    viewModel.cameraController = controller
                }
            }
            .clipShape(.circle)
    }
    
    @ViewBuilder
    private var buttonsView: some View {
        HStack {
            Spacer()
            Button {
                viewModel.cameraController?.switchCamera()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
            }
            
            recordButton
            
            Button {
                viewModel.cameraController?.switchTorch()
            } label: {
                Image(systemName: "flashlight.off.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private var recordButton: some View {
        ZStack {
            Circle()
                .fill(viewModel.state == .readyToRecord ? .red : .clear)
                .padding(2)
            Circle()
                .stroke(.red, lineWidth: 2)
        }
        .frame(width: 70, height: 70)
        .overlay(alignment: .center) {
            switch viewModel.state {
            case .readyToRecord, .failed:
                EmptyView()
            case .preparing:
                ProgressView()
            case .recording:
                Text("\(viewModel.countdown)")
                    .font(.largeTitle)
                    .transition(.slide)
            }
        }
        .onTapGesture {
            guard viewModel.state == .readyToRecord else { return }
            viewModel.startRecording()
          withAnimation(.easeInOut.repeatForever()) {
            isAnimated = true
          }
        }
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private var errorView: some View {
        Text("Camera capture failed")
            .font(.title2)
            .foregroundStyle(.red)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.red.opacity(0.3))
            }
            .padding()
    }
}

#Preview {
    DemoCameraView()
}
