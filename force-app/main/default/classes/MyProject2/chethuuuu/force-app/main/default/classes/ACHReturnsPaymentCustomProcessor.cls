public class ACHReturnsPaymentCustomProcessor extends loan.ACHReturnPaymentProcessor {
    public List<loan.ACHReturn> achReturns = new List<loan.ACHReturn>();

    public override List<loan.ACHReturn> parseFile(String fileContent, String objectType) {
        return achReturns;
    }
}