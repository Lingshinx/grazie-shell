pragma Singleton
import QtQml
QtObject {
    function groupBy(array, keyGetter) {
        const result = {};
        for (const item of array) {
            const key = keyGetter(item);
            if (!result[key]) result[key] = [];
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

    function formatBytes(bytes, fix = 1) {
        if (bytes <= 0) return "0 B/s"
        const k = 1024
        const sizes = ["B/s", "KB/s", "MB/s", "GB/s"]
        const i = Math.floor(Math.log(bytes) / Math.log(k))
        return parseFloat((bytes / Math.pow(k, i)).toFixed(fix)) + " " + sizes[i]
    }
}
