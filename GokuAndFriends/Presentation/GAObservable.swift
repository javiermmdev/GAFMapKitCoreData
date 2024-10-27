import Foundation

/// Creates a generic observable type with a property to store the observed value and an initializer for easy setup.
/// The stored value is private to prevent accidental modifications.
class GAObservable<ObservedType> {
    
    // Private stored value
    private var _value: ObservedType
    
    /// Sends the current value to any observing closure
    private var valueChanged: ((ObservedType) -> Void)?
    
    /// Public property allowing safe manipulation of the stored value.
    /// This is separate from `_value`, which remains private – designed to be modified from anywhere in the app.
    /// Both properties update together, with `_value` changing and notifying observers via the `valueChanged` closure.
    /// An alternative could be a public function to update `_value` and another to retrieve it, rather than using
    /// a computed property with get and set observers.
    var value: ObservedType {
        get {
            return _value
        }
        set {
            _value = newValue
            DispatchQueue.main.async {
                self.valueChanged?(self._value)
            }
        }
    }
    
    /// Initializes the observable with an initial value.
    init(_ value: ObservedType) {
        self._value = value
    }
    
    /// Assigns the observing closure to `valueChanged`.
    /// - Parameter completion: Closure to execute whenever the value changes.
    func bind(completion: ((ObservedType) -> Void)?) {
        valueChanged = completion
    }
}
