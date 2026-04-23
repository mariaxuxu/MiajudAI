// Simple logger middleware
const logger = (req, res, next) => {
  const start = Date.now();

  // Intercept response.json to log response
  const originalJson = res.json.bind(res);

  res.json = (body) => {
    const duration = Date.now() - start;

    console.log({
      timestamp: new Date().toISOString(),
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
    });

    return originalJson(body);
  };

  next();
};

export default logger;
