// .pragma library

function groupBy(array, keyGetter) {
  const result = {};
  for (const item of array) {
    const key = keyGetter(item);
    if (!result[key]) {
      result[key] = [];
    }
    result[key].push(item);
  }
  return result;
}

function indexBy(array, keyGetter) {
  const result = {};
  for (const item of array) {
    result[keyGetter(item)] = item;
  }
  return result;
}
