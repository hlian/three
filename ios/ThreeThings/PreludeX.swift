extension Optional {
    func orElse(_ elsa: Wrapped) -> Wrapped {
        if let x = self {
            return x
        } else {
            return elsa
        }
    }
}
