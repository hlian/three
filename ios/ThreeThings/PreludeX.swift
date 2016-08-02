extension Optional {
    func orElse(elsa: Wrapped) -> Wrapped {
        if let x = self {
            return x
        } else {
            return elsa
        }
    }
}