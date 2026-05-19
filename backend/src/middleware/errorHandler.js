// Global error handler middleware
const errorHandler = (err, req, res, next) => {
  console.error('Error:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  // Default error values
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';
  let details = err.details || null;

  // Handle specific error types
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation Error';
    details = err.errors;
  }

  if (err.name === 'UnauthorizedError') {
    statusCode = 401;
    message = 'Unauthorized';
  }

  if (err.name === 'NotFoundError') {
    statusCode = 404;
    message = 'Not Found';
  }

  if (err.name === 'ConflictError') {
    statusCode = 409;
    message = 'Conflict';
  }

  // Sequelize errors
  if (err.name === 'SequelizeValidationError') {
    statusCode = 400;
    message = 'Validation Error';
    details = err.errors.map((e) => ({
      field: e.path,
      message: e.message,
    }));
  }

  if (err.name === 'SequelizeUniqueConstraintError') {
    statusCode = 409;
    message = 'Conflict: Resource already exists';
    details = err.errors.map((e) => ({
      field: e.path,
      message: e.message,
    }));
  }

  // Send error response
  res.status(statusCode).json({
    error: {
      statusCode,
      message,
      details,
      timestamp: new Date().toISOString(),
    },
  });
};

export default errorHandler;
