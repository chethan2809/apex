public class ClassFactoryManager {
    public Object newClassInstance(String className) {
        Type newInstanceOfClass = Type.forName(className);
        return newInstanceOfClass.newInstance();
    }
}