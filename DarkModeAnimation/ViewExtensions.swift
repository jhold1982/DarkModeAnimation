//
//  ViewExtensions.swift
//  DarkModeAnimation
//
//  Created by Justin Hold on 10/4/23.
//

import SwiftUI

extension View {
	@ViewBuilder
	// Returns the Views position in screen coordinate space
	func rect(value: @escaping (CGRect) -> ()) -> some View {
		self
			.overlay {
				GeometryReader(content: { geometry in
					let rect = geometry.frame(in: .global)
					
					Color.clear
						.preference(key: RectKey.self, value: rect)
						.onPreferenceChange(RectKey.self, perform: { rect in
							value(rect)
						})
				})
			}
	}
	
	@MainActor
	@ViewBuilder
	func createImages(
		toggleDarkMode: Bool,
		currentImage: Binding<UIImage?>,
		previousImage: Binding<UIImage?>,
		activateDarkMode: Binding<Bool>
	) -> some View {
		self
			.onChange(of: toggleDarkMode) { oldValue, newValue in
				Task {
					if let window = (
						UIApplication.shared.connectedScenes.first as? UIWindowScene
					)?.windows.first(where: { $0.isKeyWindow }) {
						
						let imageView = UIImageView()
						imageView.frame = window.frame
						imageView.image = window.rootViewController?.view.image(window.frame.size)
						imageView.contentMode = .scaleAspectFit
						window.addSubview(imageView)
						
						if let rootView = window.rootViewController?.view {
							let frameSize = rootView.frame.size
							// Creating Snapshots
							/// Old one
							activateDarkMode.wrappedValue = !newValue
							previousImage.wrappedValue = rootView.image(frameSize)
//							try await Task.sleep(for: .seconds(0.01))
							/// New One with updated trait state
							activateDarkMode.wrappedValue = newValue
							/// giving time to complete transition
							try await Task.sleep(for: .seconds(0.01))
							currentImage.wrappedValue = rootView.image(frameSize)
							
							// Removing once the snapshots have been taken
							try await Task.sleep(for: .seconds(0.01))
							imageView.removeFromSuperview() 
						}
					}
				}
			}
	}
}

// Converting UIView to UIImage
extension UIView {
	func image(_ size: CGSize) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { _ in
			drawHierarchy(in: .init(origin: .zero, size: size), afterScreenUpdates: true)
		}
	}
}

