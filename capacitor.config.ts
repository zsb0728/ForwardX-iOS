import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.forwardx.app',
  appName: 'ForwardX',
  webDir: 'web',
  server: {
    iosScheme: 'forwardx',
    cleartext: true,
  },
  ios: {
    backgroundColor: '#f7f9fc',
    contentInset: 'automatic',
    preferredContentMode: 'mobile',
    scrollEnabled: true,
  },
  plugins: {
    LocalNotifications: {}
  }
};
export default config;
