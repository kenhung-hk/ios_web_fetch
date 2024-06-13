import { NativeModules } from 'react-native';

const { WebFetchModule } = NativeModules;

interface WebFetchModuleInterface {
  performFetch: (
    url: string,
    method: string,
    headers: { [key: string]: string },
    body: string
  ) => Promise<string>;
}

export const performFetch = (url: string, method: string, headers: { [key: string]: string }, body: string): Promise<string> => {
  return (WebFetchModule as WebFetchModuleInterface).performFetch(url, method, headers, body);
};
