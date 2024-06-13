import React, { useState } from 'react';
import { View, Text, Button, StyleSheet } from 'react-native';
import { performFetch } from './WebFetchModule';

const App: React.FC = () => {
  const [result, setResult] = useState<string>('');

  const fetchData = async () => {
    try {
      const res = await performFetch('https://example.com', 'GET', {}, '');
      setResult(res);
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <View style={styles.container}>
      <Button title="Fetch Data" onPress={fetchData} />
      <Text>{result}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default App;
