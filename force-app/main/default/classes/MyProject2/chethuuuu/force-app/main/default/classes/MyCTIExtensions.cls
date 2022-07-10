global class MyCTIExtensions implements
    purecloud.CTIExtension.ScreenPop{
    
    public String onScreenPop(String data) {
        System.debug('Fetchingdata+++++'+data);
        return data;
    }

}